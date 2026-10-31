-- SPDX-License-Identifier: Apache-2.0
-- Importé de https://github.com/RegalPine/hmmp-dissector-lua,
-- commit e7530781b3aca73c46c16c40107ec90a5f5d054d du 27/07/2026.
-- Licence amont : Apache-2.0 (LICENSE amont) — voir README.md.

--[=[
    HMMP (High-Performance Microservice Multiplex Protocol) Wireshark Dissector
    Protocol Version: 07
    Based on: draft-gemini-hmmp-core-07 and extensions

    Usage:
      1. Place this file in Wireshark plugins directory
         (Help -> About Wireshark -> Folders -> Personal Lua Plugins)
      2. Or load manually: Analyze -> Reload Lua Plugins
      3. Default port: 8847. Change via:
         Edit -> Preferences -> Protocols -> HMMP -> Port
--]=]

-- ============================================================
-- Protocol Registration
-- ============================================================
local hmmp = Proto("HMMP", "High-Performance Microservice Multiplex Protocol")

-- Configuration: default TCP port
hmmp.prefs.port = Pref.uint("HMMP TCP Port", 8847, "TCP port for HMMP protocol")

-- ============================================================
-- Constants
-- ============================================================
local MAGIC = 0x5153

-- bit32 compatibility (Lua 5.4 removed bit32, Wireshark may provide shim)
if not bit32 then
    bit32 = require("bit")
end

-- OpCode Map (aligned with hmmp-protocol/src/opcode.rs)
local OPCODES = {
    -- 基础连接管理 (0x0001-0x0008)
    [0x0001] = "HandshakeRequest",
    [0x0002] = "HandshakeResponse",
    [0x0003] = "HeartbeatPing",
    [0x0004] = "HeartbeatPong",
    [0x0005] = "ClusterNodeRedirectNotify",
    [0x0006] = "InstanceShutdownPrepareNotice",
    [0x0007] = "NonceChallengeRequest",
    [0x0008] = "NonceChallengeResponse",
    -- 命名与服务发现 (0x0100-0x01FF)
    [0x0101] = "RegisterInstanceRequest",
    [0x0102] = "RegisterInstanceResponse",
    [0x0103] = "DeregisterInstanceRequest",
    [0x0104] = "DeregisterInstanceResponse",
    [0x0105] = "DiscoverServiceRequest",
    [0x0106] = "DiscoverServiceResponse",
    [0x0107] = "ServiceSubscribeRequest",
    [0x0108] = "ServiceChangedNotify",
    [0x0109] = "RegisterInstanceWithMetaRequest",
    [0x010A] = "RegisterInstanceWithMetaResponse",
    [0x010B] = "DiscoverServiceByFilterRequest",
    [0x010C] = "DiscoverServiceByFilterResponse",
    -- 配置管理 (0x0200-0x02FF)
    [0x0201] = "GetConfigRequest",
    [0x0202] = "ConfigResponse",
    [0x0203] = "ListenConfigRequest",
    [0x0204] = "ConfigChangedNotify",
    -- 集群控制平面 (0x0300-0x03FF)
    [0x0301] = "RaftAppendEntriesReq",
    [0x0302] = "RaftAppendEntriesRes",
    [0x0303] = "RaftRequestVoteReq",
    [0x0304] = "RaftRequestVoteRes",
    [0x0311] = "DistroSyncDataReq",
    [0x0312] = "ClusterNodeLoadReport",
    [0x0313] = "ClusterLeaderRedirectCommand",
    -- 管理平面 (0x0400-0x04FF)
    [0x0401] = "AdminListServicesReq",
    [0x0402] = "AdminListServicesRes",
    [0x0403] = "AdminPutConfigReq",
    [0x0404] = "AdminPutConfigRes",
    [0x0405] = "AdminMigrationReq",
    [0x0406] = "AdminMigrationRes",
    [0x0407] = "AdminListTenantsReq",
    [0x0408] = "AdminListTenantsRes",
    [0x0409] = "AdminListConfigsReq",
    [0x040A] = "AdminListConfigsRes",
    [0x040B] = "AdminDeleteConfigReq",
    [0x040C] = "AdminDeleteConfigRes",
    [0x040D] = "AdminGetTenantPolicyReq",
    [0x040E] = "AdminGetTenantPolicyRes",
    [0x040F] = "AdminGetGovernanceStateReq",
    [0x0410] = "AdminGetGovernanceStateRes",
    [0x0411] = "AdminCreateTenantReq",
    [0x0412] = "AdminCreateTenantRes",
    [0x0413] = "AdminUpdateTenantPolicyReq",
    [0x0414] = "AdminUpdateTenantPolicyRes",
    [0x0415] = "AdminDeleteTenantReq",
    [0x0416] = "AdminDeleteTenantRes",
    [0x0417] = "AdminGetTenantStatsReq",
    [0x0418] = "AdminGetTenantStatsRes",
    [0x0419] = "AdminCreateCredentialReq",
    [0x041A] = "AdminCreateCredentialRes",
    [0x041B] = "AdminUpdateCredentialReq",
    [0x041C] = "AdminUpdateCredentialRes",
    [0x041D] = "AdminDeleteCredentialReq",
    [0x041E] = "AdminDeleteCredentialRes",
    [0x041F] = "AdminListCredentialsReq",
    [0x0420] = "AdminListCredentialsRes",
    [0x0421] = "AdminQueryConfigListenersReq",
    [0x0422] = "AdminQueryConfigListenersRes",
}

-- Flags
local FLAG_REQUEST      = 0x01
local FLAG_COMPRESSION  = 0x02
local FLAG_BACKPRESSURE = 0x04
local FLAG_REDIRECT     = 0x08
local FLAG_ENCRYPTED    = 0x10
local FLAG_PROBING      = 0x40
local FLAG_GOVERNANCE   = 0x80

-- All ProtoFields in a single table to stay under Lua 200 locals limit
local F = {
    f_magic = ProtoField.uint16("hmmp.magic", "Magic Number", base.HEX),
    f_version = ProtoField.uint8("hmmp.version", "Version", base.HEX),
    f_flags = ProtoField.uint8("hmmp.flags", "Flags", base.HEX),
    f_stream_id = ProtoField.uint32("hmmp.stream_id", "Stream ID", base.DEC),
    f_payload_len = ProtoField.uint32("hmmp.payload_length", "Payload Length", base.DEC),
    f_padding = ProtoField.uint32("hmmp.padding", "Padding", base.HEX),
    f_flag_request = ProtoField.bool("hmmp.flags.request", "Request", 8, nil, FLAG_REQUEST),
    f_flag_compression = ProtoField.bool("hmmp.flags.compression", "Compression (Zstd)", 8, nil, FLAG_COMPRESSION),
    f_flag_backpressure = ProtoField.bool("hmmp.flags.backpressure", "Backpressure", 8, nil, FLAG_BACKPRESSURE),
    f_flag_redirect = ProtoField.bool("hmmp.flags.redirect", "Node Redirect", 8, nil, FLAG_REDIRECT),
    f_flag_encrypted = ProtoField.bool("hmmp.flags.encrypted", "Encrypted", 8, nil, FLAG_ENCRYPTED),
    f_flag_probing = ProtoField.bool("hmmp.flags.probing", "Probing", 8, nil, FLAG_PROBING),
    f_flag_governance = ProtoField.bool("hmmp.flags.governance", "Governance Present", 8, nil, FLAG_GOVERNANCE),
    f_meta_len = ProtoField.uint16("hmmp.metadata_length", "Metadata Length", base.DEC),
    f_meta_raw = ProtoField.bytes("hmmp.metadata_raw", "Metadata (MessagePack)"),
    f_md_entry = ProtoField.string("hmmp.md.entry", "Metadata Entry"),
    f_md_key = ProtoField.string("hmmp.md.key", "Key"),
    f_md_value = ProtoField.string("hmmp.md.value", "Value"),
    f_body_type = ProtoField.uint16("hmmp.body_type", "Body Type (OpCode)", base.HEX),
    f_body_type_name = ProtoField.string("hmmp.body_type_name", "Command Name"),
    f_gov_len = ProtoField.uint32("hmmp.governance.length", "Governance Block Length", base.DEC),
    f_gov_tag_type = ProtoField.uint8("hmmp.governance.tag_type", "Tag Type", base.HEX),
    f_gov_tag_len = ProtoField.uint16("hmmp.governance.tag_length", "Tag Length", base.DEC),
    f_gov_tag_val = ProtoField.bytes("hmmp.governance.tag_value", "Tag Value"),
    f_gov_trace_id = ProtoField.bytes("hmmp.governance.trace_id", "Trace ID"),
    f_gov_span_id = ProtoField.bytes("hmmp.governance.span_id", "Span ID"),
    f_gov_coloring = ProtoField.string("hmmp.governance.traffic_coloring", "Traffic Coloring"),
    f_gov_queue_us = ProtoField.uint32("hmmp.governance.queue_duration_us", "Queue Duration (us)", base.DEC),
    f_gov_exec_ms = ProtoField.uint32("hmmp.governance.exec_duration_ms", "Exec Duration (ms)", base.DEC),
    f_enc_iv_len = ProtoField.uint8("hmmp.encrypted.iv_len", "IV Length", base.DEC),
    f_enc_iv = ProtoField.bytes("hmmp.encrypted.iv", "Initialization Vector"),
    f_enc_ct_len = ProtoField.uint32("hmmp.encrypted.ciphertext_len", "Ciphertext Length", base.DEC),
    f_enc_ct = ProtoField.bytes("hmmp.encrypted.ciphertext", "Ciphertext"),
    f_svc_len = ProtoField.uint16("hmmp.svc_len", "Service Name Length", base.DEC),
    f_svc_name = ProtoField.string("hmmp.service_name", "Service Name"),
    f_ip_type = ProtoField.uint8("hmmp.ip_type", "IP Type", base.HEX),
    f_port = ProtoField.uint16("hmmp.port", "Port", base.DEC),
    f_ephemeral = ProtoField.uint8("hmmp.ephemeral", "Ephemeral", base.DEC),
    f_ip_address = ProtoField.bytes("hmmp.ip_address", "IP Address"),
    f_weight = ProtoField.float("hmmp.weight", "Weight"),
    f_metrics_pack = ProtoField.uint32("hmmp.metrics_pack", "Metrics Pack", base.HEX),
    f_metadata_hash = ProtoField.uint64("hmmp.metadata_hash", "Metadata Hash", base.HEX),
    f_mp_cpu = ProtoField.uint32("hmmp.metrics.cpu", "CPU (%)", base.DEC),
    f_mp_mem = ProtoField.uint32("hmmp.metrics.memory", "Memory (%)", base.DEC),
    f_mp_conns = ProtoField.uint32("hmmp.metrics.active_conns", "Active Connections", base.DEC),
    f_mp_delay = ProtoField.uint32("hmmp.metrics.ewma_delay", "EWMA Delay", base.DEC),
    f_mp_error = ProtoField.bool("hmmp.metrics.error", "Error Flag", 32, nil, 0x20000000),
    f_mp_preheat = ProtoField.bool("hmmp.metrics.preheating", "Pre-heating Flag", 32, nil, 0x40000000),
    f_mp_scale = ProtoField.bool("hmmp.metrics.delay_scale", "Delay Scale (10ms)", 32, nil, 0x80000000),
    f_client_id_len = ProtoField.uint8("hmmp.client_id_len", "Client ID Length", base.DEC),
    f_client_id = ProtoField.string("hmmp.client_id", "Client ID"),
    f_access_key_len = ProtoField.uint8("hmmp.access_key_len", "Access Key Length", base.DEC),
    f_access_key = ProtoField.string("hmmp.access_key", "Access Key"),
    f_timestamp = ProtoField.uint64("hmmp.timestamp", "Timestamp (ms)", base.DEC),
    f_sig_len = ProtoField.uint8("hmmp.signature_len", "Signature Length", base.DEC),
    f_signature = ProtoField.string("hmmp.signature", "Signature (HMAC-SHA256)"),
    f_nonce_present = ProtoField.uint8("hmmp.nonce_present", "Nonce Present", base.DEC),
    f_server_nonce = ProtoField.bytes("hmmp.server_nonce", "Server Nonce"),
    f_label_count = ProtoField.uint8("hmmp.label_count", "Label Count", base.DEC),
    f_nonce_status = ProtoField.uint16("hmmp.nonce.status", "Status", base.HEX),
    f_nonce_ttl = ProtoField.uint32("hmmp.nonce.ttl_ms", "Nonce TTL (ms)", base.DEC),
    f_server_ts = ProtoField.uint64("hmmp.nonce.server_timestamp", "Server Timestamp (ms)", base.DEC),
    f_topology_ver = ProtoField.uint64("hmmp.topology_version", "Topology Version", base.DEC),
    f_instance_count = ProtoField.uint16("hmmp.instance_count", "Instance Count", base.DEC),
    f_is_healthy = ProtoField.uint8("hmmp.is_healthy", "Healthy", base.DEC),
    f_addr_family = ProtoField.uint16("hmmp.address_family", "Address Family", base.HEX),
    f_tenant_len = ProtoField.uint16("hmmp.tenant_len", "Tenant Length", base.DEC),
    f_tenant = ProtoField.string("hmmp.tenant", "Tenant"),
    f_group_len = ProtoField.uint16("hmmp.group_len", "Group Length", base.DEC),
    f_group = ProtoField.string("hmmp.group", "Group"),
    f_data_id_len = ProtoField.uint16("hmmp.data_id_len", "Data ID Length", base.DEC),
    f_data_id = ProtoField.string("hmmp.data_id", "Data ID"),
    f_md5 = ProtoField.bytes("hmmp.md5", "MD5 Digest"),
    f_total_chunks = ProtoField.uint16("hmmp.total_chunks", "Total Chunks", base.DEC),
    f_chunk_index = ProtoField.uint16("hmmp.chunk_index", "Chunk Index", base.DEC),
    f_is_deleted = ProtoField.uint8("hmmp.is_deleted", "Deleted", base.DEC),
    f_raw_len = ProtoField.uint32("hmmp.raw_len", "Raw Bytes Length", base.DEC),
    f_raw_bytes = ProtoField.bytes("hmmp.raw_bytes", "Raw Bytes"),
    f_listen_count = ProtoField.uint16("hmmp.listen_count", "Listen Count", base.DEC),
    f_tenant_len8 = ProtoField.uint8("hmmp.tenant_len8", "Tenant Length", base.DEC),
    f_group_len8 = ProtoField.uint8("hmmp.group_len8", "Group Length", base.DEC),
    f_data_id_len8 = ProtoField.uint8("hmmp.data_id_len8", "Data ID Length", base.DEC),
    f_current_md5 = ProtoField.bytes("hmmp.current_md5", "Current MD5"),
    f_tenant_len_u8 = ProtoField.uint8("hmmp.tenant_len_u8", "Tenant Length", base.DEC),
    f_policy_flags = ProtoField.uint16("hmmp.policy_flags", "Policy Flags", base.HEX),
    f_max_connections = ProtoField.uint32("hmmp.max_connections", "Max Connections", base.DEC),
    f_rate_limit_ops = ProtoField.uint32("hmmp.rate_limit_ops", "Rate Limit OPS", base.DEC),
    f_seq_number = ProtoField.uint32("hmmp.sequence_number", "Sequence Number", base.DEC),
    f_status_code = ProtoField.uint16("hmmp.status_code", "Status Code", base.HEX),
    f_resp_padding = ProtoField.uint16("hmmp.resp_padding", "Padding", base.HEX),
    f_lease_time = ProtoField.uint32("hmmp.lease_time_ms", "Enforced Lease Time (ms)", base.DEC),
    f_redirect_reason = ProtoField.uint8("hmmp.redirect_reason", "Redirect Reason", base.HEX),
    f_graceful_wait = ProtoField.uint16("hmmp.graceful_wait_ms", "Graceful Wait (ms)", base.DEC),
    f_target_ip_type = ProtoField.uint8("hmmp.target_ip_type", "Target IP Type", base.HEX),
    f_target_port = ProtoField.uint16("hmmp.target_port", "Target Port", base.DEC),
    f_target_ip = ProtoField.bytes("hmmp.target_ip", "Target IP Address"),
    f_term = ProtoField.uint64("hmmp.raft.term", "Term", base.DEC),
    f_leader_id = ProtoField.uint64("hmmp.raft.leader_id", "Leader ID", base.DEC),
    f_prev_log_idx = ProtoField.uint64("hmmp.raft.prev_log_index", "Prev Log Index", base.DEC),
    f_prev_log_term = ProtoField.uint64("hmmp.raft.prev_log_term", "Prev Log Term", base.DEC),
    f_leader_commit = ProtoField.uint64("hmmp.raft.leader_commit", "Leader Commit", base.DEC),
    f_entry_count = ProtoField.uint16("hmmp.raft.entry_count", "Entry Count", base.DEC),
    f_entry_index = ProtoField.uint64("hmmp.raft.entry_index", "Entry Index", base.DEC),
    f_entry_term = ProtoField.uint64("hmmp.raft.entry_term", "Entry Term", base.DEC),
    f_inner_opcode = ProtoField.uint16("hmmp.raft.inner_opcode", "Inner OpCode", base.HEX),
    f_payload_len_raft = ProtoField.uint32("hmmp.raft.payload_len", "Payload Length", base.DEC),
    f_cmd_payload = ProtoField.bytes("hmmp.raft.command_payload", "Command Payload"),
    f_match_log_idx = ProtoField.uint64("hmmp.raft.match_log_index", "Match Log Index", base.DEC),
    f_success = ProtoField.uint8("hmmp.raft.success", "Success", base.DEC),
    f_raft_padding = ProtoField.bytes("hmmp.raft.padding", "Padding"),
    f_candidate_id = ProtoField.uint64("hmmp.raft.candidate_id", "Candidate ID", base.DEC),
    f_last_log_idx = ProtoField.uint64("hmmp.raft.last_log_index", "Last Log Index", base.DEC),
    f_last_log_term = ProtoField.uint64("hmmp.raft.last_log_term", "Last Log Term", base.DEC),
    f_vote_granted = ProtoField.uint8("hmmp.raft.vote_granted", "Vote Granted", base.DEC),
    f_source_server_id = ProtoField.uint64("hmmp.distro.source_server_id", "Source Server ID", base.DEC),
    f_shard_version = ProtoField.uint64("hmmp.distro.shard_version", "Shard Version", base.DEC),
    f_sync_type = ProtoField.uint8("hmmp.distro.sync_type", "Sync Type", base.HEX),
    f_service_key_len = ProtoField.uint16("hmmp.distro.service_key_len", "Service Key Length", base.DEC),
    f_service_key = ProtoField.string("hmmp.distro.service_key", "Service Key"),
    f_active_conns = ProtoField.uint32("hmmp.distro.active_connections", "Active Connections", base.DEC),
    f_real_ip_type = ProtoField.uint8("hmmp.distro.real_ip_type", "Real IP Type", base.HEX),
    f_real_port = ProtoField.uint16("hmmp.distro.real_port", "Real Port", base.DEC),
    f_instance_data = ProtoField.bytes("hmmp.distro.instance_data", "Instance Data"),
    f_node_id = ProtoField.uint64("hmmp.load.node_id", "Node ID", base.DEC),
    f_load_term = ProtoField.uint64("hmmp.load.term", "Term", base.DEC),
    f_load_conns = ProtoField.uint32("hmmp.load.active_connections", "Active Connections", base.DEC),
    f_load_metrics = ProtoField.uint32("hmmp.load.metrics_pack", "Metrics Pack", base.HEX),
    f_leader_term = ProtoField.uint64("hmmp.redirect.leader_term", "Leader Term", base.DEC),
    f_target_stream = ProtoField.uint32("hmmp.redirect.target_stream_id", "Target Stream ID", base.DEC),
    f_dest_ip_type = ProtoField.uint8("hmmp.redirect.dest_ip_type", "Dest IP Type", base.HEX),
    f_dest_port = ProtoField.uint16("hmmp.redirect.dest_port", "Dest Port", base.DEC),
    f_dest_ip = ProtoField.bytes("hmmp.redirect.dest_ip", "Dest IP Address"),
    f_shutdown_delay = ProtoField.uint32("hmmp.shutdown_delay_ms", "Shutdown Delay (ms)", base.DEC),
    f_meta_count = ProtoField.uint16("hmmp.meta_count", "Metadata Count", base.DEC),
    f_meta_key_len = ProtoField.uint8("hmmp.meta_key_len", "Key Length", base.DEC),
    f_meta_key = ProtoField.string("hmmp.meta_key", "Key"),
    f_meta_val_len = ProtoField.uint16("hmmp.meta_val_len", "Value Length", base.DEC),
    f_meta_val = ProtoField.string("hmmp.meta_val", "Value"),
    f_filter_expr_len = ProtoField.uint16("hmmp.filter_expr_len", "Filter Expr Length", base.DEC),
    f_filter_expr = ProtoField.bytes("hmmp.filter_expr", "Filter Expression"),
    f_include_metadata = ProtoField.uint8("hmmp.include_metadata", "Include Metadata", base.DEC),
    f_total_count = ProtoField.uint16("hmmp.total_count", "Total Count (before filter)", base.DEC),
    f_lease_duration = ProtoField.uint64("hmmp.admin.lease_duration_ms", "Lease Duration (ms)", base.DEC),
    f_force = ProtoField.uint8("hmmp.admin.force", "Force Delete", base.DEC),
    f_found = ProtoField.uint8("hmmp.admin.found", "Found", base.DEC),
    f_reg_services = ProtoField.uint16("hmmp.admin.registered_services", "Registered Services", base.DEC),
    f_reg_instances = ProtoField.uint32("hmmp.admin.registered_instances", "Registered Instances", base.DEC),
    f_credential_count = ProtoField.uint16("hmmp.admin.credential_count", "Credential Count", base.DEC),
    f_config_count = ProtoField.uint32("hmmp.admin.config_count", "Config Count", base.DEC),
    -- Admin list/service fields
    f_service_count = ProtoField.uint16("hmmp.admin.service_count", "Service Count", base.DEC),
    f_content_len = ProtoField.uint32("hmmp.admin.content_len", "Content Length", base.DEC),
    f_content = ProtoField.bytes("hmmp.admin.content", "Content"),
    f_source_node_id = ProtoField.uint64("hmmp.admin.source_node_id", "Source Node ID", base.DEC),
    f_target_node_id = ProtoField.uint64("hmmp.admin.target_node_id", "Target Node ID", base.DEC),
    f_migration_stream = ProtoField.uint32("hmmp.admin.migration_stream_id", "Stream ID", base.DEC),
    f_migration_wait = ProtoField.uint32("hmmp.admin.graceful_wait_ms", "Graceful Wait (ms)", base.DEC),
    f_tenant_count = ProtoField.uint16("hmmp.admin.tenant_count", "Tenant Count", base.DEC),
    f_lease_expiry = ProtoField.uint64("hmmp.admin.lease_expiry_ms", "Lease Expiry (ms)", base.DEC),
    f_admin_success = ProtoField.uint8("hmmp.admin.success", "Success", base.DEC),
    -- Governance state fields
    f_cb_count = ProtoField.uint16("hmmp.gov.cb_count", "Circuit Breaker Count", base.DEC),
    f_cb_state = ProtoField.uint8("hmmp.gov.cb_state", "CB State", base.DEC),
    f_cb_error_rate = ProtoField.uint16("hmmp.gov.cb_error_rate", "Error Rate (bp)", base.DEC),
    f_cb_threshold = ProtoField.uint16("hmmp.gov.cb_threshold", "Threshold (bp)", base.DEC),
    f_cb_opened_at = ProtoField.uint64("hmmp.gov.cb_opened_at_ms", "Opened At (ms)", base.DEC),
    f_coloring_count = ProtoField.uint16("hmmp.gov.coloring_count", "Coloring Rule Count", base.DEC),
    f_coloring_tag = ProtoField.string("hmmp.gov.coloring_tag", "Coloring Tag"),
    f_coloring_target_count = ProtoField.uint8("hmmp.gov.coloring_target_count", "Target Count", base.DEC),
    f_outlier_count = ProtoField.uint16("hmmp.gov.outlier_count", "Outlier Vote Count", base.DEC),
    f_suspect_node_id = ProtoField.uint64("hmmp.gov.suspect_node_id", "Suspect Node ID", base.DEC),
    f_voter_count = ProtoField.uint8("hmmp.gov.voter_count", "Voter Count", base.DEC),
    f_outlier_threshold = ProtoField.uint16("hmmp.gov.outlier_threshold", "Outlier Threshold", base.DEC),
    -- Credential management fields
    f_client_id_len16 = ProtoField.uint16("hmmp.admin.client_id_len", "Client ID Length", base.DEC),
    f_client_id_str = ProtoField.string("hmmp.admin.client_id", "Client ID"),
    f_secret_len = ProtoField.uint16("hmmp.admin.secret_len", "Secret Length", base.DEC),
    f_secret = ProtoField.string("hmmp.admin.secret", "Secret"),
    f_node_type_len = ProtoField.uint16("hmmp.admin.node_type_len", "Node Type Length", base.DEC),
    f_node_type = ProtoField.string("hmmp.admin.node_type", "Node Type"),
    f_enabled = ProtoField.uint8("hmmp.admin.enabled", "Enabled", base.DEC),
    f_created_at = ProtoField.uint64("hmmp.admin.created_at", "Created At (ms)", base.DEC),
    f_has_field = ProtoField.uint8("hmmp.admin.has_field", "Present", base.DEC),
    -- Config listener fields
    f_listener_count = ProtoField.uint16("hmmp.admin.listener_count", "Listener Count", base.DEC),
    f_peer_addr_len = ProtoField.uint16("hmmp.admin.peer_addr_len", "Peer Addr Length", base.DEC),
    f_peer_addr = ProtoField.string("hmmp.admin.peer_addr", "Peer Address"),
    f_registered_at = ProtoField.uint64("hmmp.admin.registered_at", "Registered At (ms)", base.DEC),
}

-- Register fields
hmmp.fields = {
    F.f_magic, F.f_version, F.f_flags, F.f_stream_id, F.f_payload_len, F.f_padding,
    F.f_flag_request, F.f_flag_compression, F.f_flag_backpressure, F.f_flag_redirect,
    F.f_flag_encrypted, F.f_flag_probing, F.f_flag_governance,
    F.f_meta_len, F.f_meta_raw, F.f_md_entry, F.f_md_key, F.f_md_value, F.f_body_type, F.f_body_type_name,
    F.f_gov_len, F.f_gov_tag_type, F.f_gov_tag_len, F.f_gov_tag_val,
    F.f_gov_trace_id, F.f_gov_span_id, F.f_gov_coloring, F.f_gov_queue_us, F.f_gov_exec_ms,
    F.f_enc_iv_len, F.f_enc_iv, F.f_enc_ct_len, F.f_enc_ct,
    F.f_svc_len, F.f_svc_name, F.f_ip_type, F.f_port, F.f_ephemeral, F.f_ip_address,
    F.f_weight, F.f_metrics_pack, F.f_metadata_hash,
    F.f_mp_cpu, F.f_mp_mem, F.f_mp_conns, F.f_mp_delay, F.f_mp_error, F.f_mp_preheat, F.f_mp_scale,
    F.f_client_id_len, F.f_client_id, F.f_access_key_len, F.f_access_key,
    F.f_timestamp, F.f_sig_len, F.f_signature, F.f_nonce_present, F.f_server_nonce, F.f_label_count,
    F.f_nonce_status, F.f_nonce_ttl, F.f_server_ts,
    F.f_topology_ver, F.f_instance_count, F.f_is_healthy,
    F.f_addr_family,
    F.f_tenant_len, F.f_tenant, F.f_group_len, F.f_group, F.f_data_id_len, F.f_data_id,
    F.f_md5, F.f_total_chunks, F.f_chunk_index, F.f_is_deleted, F.f_raw_len, F.f_raw_bytes,
    F.f_listen_count, F.f_tenant_len8, F.f_group_len8, F.f_data_id_len8, F.f_current_md5,
    F.f_tenant_len_u8, F.f_policy_flags, F.f_max_connections, F.f_rate_limit_ops,
    F.f_seq_number, F.f_status_code, F.f_resp_padding, F.f_lease_time,
    F.f_redirect_reason, F.f_graceful_wait, F.f_target_ip_type, F.f_target_port, F.f_target_ip,
    F.f_term, F.f_leader_id, F.f_prev_log_idx, F.f_prev_log_term, F.f_leader_commit,
    F.f_entry_count, F.f_entry_index, F.f_entry_term, F.f_inner_opcode, F.f_payload_len_raft, F.f_cmd_payload,
    F.f_match_log_idx, F.f_success, F.f_raft_padding,
    F.f_candidate_id, F.f_last_log_idx, F.f_last_log_term, F.f_vote_granted,
    F.f_source_server_id, F.f_shard_version, F.f_sync_type, F.f_service_key_len, F.f_service_key,
    F.f_active_conns, F.f_real_ip_type, F.f_real_port, F.f_instance_data,
    F.f_node_id, F.f_load_term, F.f_load_conns, F.f_load_metrics,
    F.f_leader_term, F.f_target_stream, F.f_dest_ip_type, F.f_dest_port, F.f_dest_ip,
    F.f_shutdown_delay,
    F.f_meta_count, F.f_meta_key_len, F.f_meta_key, F.f_meta_val_len, F.f_meta_val,
    F.f_filter_expr_len, F.f_filter_expr, F.f_include_metadata, F.f_total_count,
    F.f_lease_duration, F.f_force, F.f_found, F.f_reg_services, F.f_reg_instances,
    F.f_credential_count, F.f_config_count,
    F.f_service_count, F.f_content_len, F.f_content, F.f_source_node_id, F.f_target_node_id,
    F.f_migration_stream, F.f_migration_wait, F.f_tenant_count, F.f_lease_expiry, F.f_admin_success,
    F.f_cb_count, F.f_cb_state, F.f_cb_error_rate, F.f_cb_threshold, F.f_cb_opened_at,
    F.f_coloring_count, F.f_coloring_tag, F.f_coloring_target_count,
    F.f_outlier_count, F.f_suspect_node_id, F.f_voter_count, F.f_outlier_threshold,
    F.f_secret_len, F.f_secret, F.f_node_type_len, F.f_node_type, F.f_enabled, F.f_created_at, F.f_has_field,
    F.f_client_id_len16, F.f_client_id_str,
    F.f_listener_count, F.f_peer_addr_len, F.f_peer_addr, F.f_registered_at,
}

-- ============================================================
-- Helper Functions (wrapped in do...end to reduce main-chunk locals)
-- ============================================================
do
local _M = {}

--- Extract IPv4 or IPv6 address string from TvbRange
function _M.extract_ip(tvb_range, ip_type)
    if ip_type == 4 then
        return string.format("%d.%d.%d.%d",
            tvb_range:range(0,1):uint(), tvb_range:range(1,1):uint(),
            tvb_range:range(2,1):uint(), tvb_range:range(3,1):uint())
    elseif ip_type == 6 then
        local parts = {}
        for i = 0, 7 do
            parts[#parts + 1] = string.format("%04x", tvb_range:range(i*2, 2):uint())
        end
        return table.concat(parts, ":")
    end
    return tvb_range:bytes():tohex()
end

--- Parse metrics pack bit fields and add to tree
function _M.parse_metrics_pack(tree, tvb_range)
    local val = tvb_range:uint()
    local cpu_raw = bit32.rshift(val, 27)             -- Bits 0-4 (MSB)
    local mem_raw = bit32.rshift(bit32.band(val, 0x07C00000), 22)  -- Bits 5-9
    local conns   = bit32.rshift(bit32.band(val, 0x003FF000), 12)  -- Bits 10-19
    local delay   = bit32.rshift(bit32.band(val, 0x00000FF8), 3)   -- Bits 20-28
    local err_bit = bit32.rshift(bit32.band(val, 0x00000004), 2)   -- Bit 29
    local pre_bit = bit32.rshift(bit32.band(val, 0x00000002), 1)   -- Bit 30
    local scl_bit = bit32.band(val, 0x00000001)                    -- Bit 31

    local cpu_pct = string.format("%.1f", cpu_raw * 3.22)
    local mem_pct = string.format("%.1f", mem_raw * 3.22)
    local delay_ms = delay
    if scl_bit == 1 then delay_ms = delay * 10 end

    tree:add(F.f_mp_cpu, tvb_range, cpu_raw):append_text(" (" .. cpu_pct .. "%)")
    tree:add(F.f_mp_mem, tvb_range, mem_raw):append_text(" (" .. mem_pct .. "%)")
    tree:add(F.f_mp_conns, tvb_range, conns)
    tree:add(F.f_mp_delay, tvb_range, delay):append_text(" (" .. delay_ms .. " ms)")
    tree:add(F.f_mp_error, tvb_range):append_text(err_bit == 1 and " (ACTIVE)" or " (OK)")
    tree:add(F.f_mp_preheat, tvb_range):append_text(pre_bit == 1 and " (WARMING)" or " (READY)")
    tree:add(F.f_mp_scale, tvb_range):append_text(scl_bit == 1 and " (10ms)" or " (1ms)")
end

--- Parse metadata KV entries
function _M.parse_meta_entries(tree, tvb, offset, count)
    for i = 1, count do
        if offset >= tvb:len() then break end
        local entry_tree = tree:add(tvb:range(offset, 0), "Metadata Entry [" .. i .. "]")
        local key_len = tvb:range(offset, 1):uint()
        entry_tree:add(F.f_meta_key_len, tvb:range(offset, 1))
        offset = offset + 1
        if offset + key_len > tvb:len() then break end
        local key = tvb:range(offset, key_len):string()
        entry_tree:add(F.f_meta_key, tvb:range(offset, key_len))
        offset = offset + key_len
        if offset + 2 > tvb:len() then break end
        local val_len = tvb:range(offset, 2):uint()
        entry_tree:add(F.f_meta_val_len, tvb:range(offset, 2))
        offset = offset + 2
        if offset + val_len > tvb:len() then break end
        local val = tvb:range(offset, val_len):string()
        entry_tree:add(F.f_meta_val, tvb:range(offset, val_len))
        entry_tree:append_text(": " .. key .. " = " .. val)
        offset = offset + val_len
    end
    return offset
end

--- Parse instance array (snapshot format for 0x0106/0x0108)
function _M.parse_instance_array(tree, tvb, offset, count)
    for i = 1, count do
        if offset >= tvb:len() then break end
        local inst_tree = tree:add(tvb:range(offset, 0), "Instance [" .. i .. "]")
        local start = offset

        local ip_type = tvb:range(offset, 1):uint()
        inst_tree:add(F.f_ip_type, tvb:range(offset, 1))
        offset = offset + 1

        local port = tvb:range(offset, 2):uint()
        inst_tree:add(F.f_port, tvb:range(offset, 2))
        offset = offset + 2

        local healthy = tvb:range(offset, 1):uint()
        inst_tree:add(F.f_is_healthy, tvb:range(offset, 1)):append_text(healthy == 1 and " (Active)" or " (Dead)")
        offset = offset + 1

        local ip_len = (ip_type == 6) and 16 or 4
        if offset + ip_len > tvb:len() then break end
        local ip_str = _M.extract_ip(tvb:range(offset, ip_len), ip_type)
        inst_tree:add(F.f_ip_address, tvb:range(offset, ip_len)):append_text(" (" .. ip_str .. ")")
        offset = offset + ip_len

        local weight = tvb:range(offset, 4):float()
        inst_tree:add(F.f_weight, tvb:range(offset, 4))
        offset = offset + 4

        local mp_tree = inst_tree:add(F.f_metrics_pack, tvb:range(offset, 4))
        _M.parse_metrics_pack(mp_tree, tvb:range(offset, 4))
        offset = offset + 4

        inst_tree:add(F.f_metadata_hash, tvb:range(offset, 8))
        offset = offset + 8

        inst_tree:set_len(offset - start)
        inst_tree:append_text(": " .. ip_str .. ":" .. port)
    end
    return offset
end

-- ============================================================
-- Minimal MessagePack Parser (extract body_type)
-- ============================================================

--- Skip a msgpack value, return new offset
function _M.msgpack_skip(tvb, offset)
    if offset >= tvb:len() then return offset end
    local b = tvb:range(offset, 1):uint()
    offset = offset + 1

    -- positive fixint / negative fixint
    if b < 0x80 or b >= 0xe0 then return offset end
    -- fixmap
    if b >= 0x80 and b <= 0x8f then
        local n = b - 0x80
        for _ = 1, n * 2 do offset = _M.msgpack_skip(tvb, offset) end
        return offset
    end
    -- fixarray
    if b >= 0x90 and b <= 0x9f then
        local n = b - 0x90
        for _ = 1, n do offset = _M.msgpack_skip(tvb, offset) end
        return offset
    end
    -- fixstr
    if b >= 0xa0 and b <= 0xbf then
        return offset + (b - 0xa0)
    end
    -- nil, false, true
    if b >= 0xc0 and b <= 0xc3 then return offset end
    -- bin8, bin16, bin32
    if b == 0xc4 then return offset + 1 + tvb:range(offset, 1):uint() end
    if b == 0xc5 then return offset + 2 + tvb:range(offset, 2):uint() end
    if b == 0xc6 then return offset + 4 + tvb:range(offset, 4):uint() end
    -- float32, float64
    if b == 0xca then return offset + 4 end
    if b == 0xcb then return offset + 8 end
    -- uint8, uint16, uint32, uint64
    if b == 0xcc then return offset + 1 end
    if b == 0xcd then return offset + 2 end
    if b == 0xce then return offset + 4 end
    if b == 0xcf then return offset + 8 end
    -- int8, int16, int32, int64
    if b == 0xd0 then return offset + 1 end
    if b == 0xd1 then return offset + 2 end
    if b == 0xd2 then return offset + 4 end
    if b == 0xd3 then return offset + 8 end
    -- str8, str16, str32
    if b == 0xd9 then return offset + 1 + tvb:range(offset, 1):uint() end
    if b == 0xda then return offset + 2 + tvb:range(offset, 2):uint() end
    if b == 0xdb then return offset + 4 + tvb:range(offset, 4):uint() end
    -- array16, array32
    if b == 0xdc then
        local n = tvb:range(offset, 2):uint(); offset = offset + 2
        for _ = 1, n do offset = _M.msgpack_skip(tvb, offset) end
        return offset
    end
    if b == 0xdd then
        local n = tvb:range(offset, 4):uint(); offset = offset + 4
        for _ = 1, n do offset = _M.msgpack_skip(tvb, offset) end
        return offset
    end
    -- map16, map32
    if b == 0xde then
        local n = tvb:range(offset, 2):uint(); offset = offset + 2
        for _ = 1, n * 2 do offset = _M.msgpack_skip(tvb, offset) end
        return offset
    end
    if b == 0xdf then
        local n = tvb:range(offset, 4):uint(); offset = offset + 4
        for _ = 1, n * 2 do offset = _M.msgpack_skip(tvb, offset) end
        return offset
    end
    return offset
end

--- Read a msgpack string value at offset, return (string, new_offset)
function _M.msgpack_read_string(tvb, offset)
    if offset >= tvb:len() then return nil, offset end
    local b = tvb:range(offset, 1):uint()
    local start = offset
    offset = offset + 1
    local len = 0
    if b >= 0xa0 and b <= 0xbf then
        len = b - 0xa0
    elseif b == 0xd9 then
        len = tvb:range(offset, 1):uint(); offset = offset + 1
    elseif b == 0xda then
        len = tvb:range(offset, 2):uint(); offset = offset + 2
    elseif b == 0xdb then
        len = tvb:range(offset, 4):uint(); offset = offset + 4
    else
        return nil, start  -- not a string, return original offset
    end
    if offset + len > tvb:len() then return nil, start end
    local s = tvb:range(offset, len):string()
    return s, offset + len
end

--- Read a msgpack unsigned int at offset, return (value, new_offset)
function _M.msgpack_read_uint(tvb, offset)
    if offset >= tvb:len() then return nil, offset end
    local b = tvb:range(offset, 1):uint()
    offset = offset + 1
    if b < 0x80 then return b, offset end
    if b == 0xcc then local v = tvb:range(offset, 1):uint(); return v, offset + 1 end
    if b == 0xcd then local v = tvb:range(offset, 2):uint(); return v, offset + 2 end
    if b == 0xce then local v = tvb:range(offset, 4):uint(); return v, offset + 4 end
    if b == 0xcf then local v = tvb:range(offset, 8):uint64(); return tonumber(v), offset + 8 end
    return nil, offset - 1  -- not a uint, return original offset
end

--- Read any msgpack value and return a display string + new_offset
function _M.msgpack_read_any(tvb, offset)
    if offset >= tvb:len() then return "<eof>", offset end
    local b = tvb:range(offset, 1):uint()

    -- nil
    if b == 0xc0 then return "nil", offset + 1 end
    -- false / true
    if b == 0xc2 then return "false", offset + 1 end
    if b == 0xc3 then return "true", offset + 1 end

    -- positive fixint
    if b < 0x80 then return tostring(b), offset + 1 end
    -- negative fixint
    if b >= 0xe0 then return tostring(b - 256), offset + 1 end

    -- uint / int
    if b == 0xcc then return tostring(tvb:range(offset+1, 1):uint()), offset + 2 end
    if b == 0xcd then return tostring(tvb:range(offset+1, 2):uint()), offset + 3 end
    if b == 0xce then return tostring(tvb:range(offset+1, 4):uint()), offset + 5 end
    if b == 0xcf then return tostring(tonumber(tvb:range(offset+1, 8):uint64())), offset + 9 end
    if b == 0xd0 then local v = tvb:range(offset+1, 1):uint(); if v > 127 then v = v - 256 end; return tostring(v), offset + 2 end
    if b == 0xd1 then local v = tvb:range(offset+1, 2):uint(); if v > 32767 then v = v - 65536 end; return tostring(v), offset + 3 end
    if b == 0xd2 then local v = tvb:range(offset+1, 4):uint(); return tostring(v), offset + 5 end
    if b == 0xd3 then return tostring(tonumber(tvb:range(offset+1, 8):uint64())), offset + 9 end

    -- float32 / float64
    if b == 0xca then return string.format("%.6g", tvb:range(offset+1, 4):float()), offset + 5 end
    if b == 0xcb then
        -- float64: try double(), fallback to hex display
        local ok, val = pcall(function() return tvb:range(offset+1, 8):double() end)
        if ok then return string.format("%.10g", val), offset + 9 end
        return "0x" .. tvb:range(offset+1, 8):bytes():tohex(), offset + 9
    end

    -- fixstr / str8 / str16 / str32
    if b >= 0xa0 and b <= 0xbf then
        local len = b - 0xa0
        if offset + 1 + len > tvb:len() then return "<truncated>", tvb:len() end
        return tvb:range(offset + 1, len):string(), offset + 1 + len
    end
    if b == 0xd9 then
        local len = tvb:range(offset+1, 1):uint()
        if offset + 2 + len > tvb:len() then return "<truncated>", tvb:len() end
        return tvb:range(offset + 2, len):string(), offset + 2 + len
    end
    if b == 0xda then
        local len = tvb:range(offset+1, 2):uint()
        if offset + 3 + len > tvb:len() then return "<truncated>", tvb:len() end
        return tvb:range(offset + 3, len):string(), offset + 3 + len
    end
    if b == 0xdb then
        local len = tvb:range(offset+1, 4):uint()
        if offset + 5 + len > tvb:len() then return "<truncated>", tvb:len() end
        return tvb:range(offset + 5, len):string(), offset + 5 + len
    end

    -- bin8 / bin16 / bin32 (show as hex)
    if b == 0xc4 then
        local len = tvb:range(offset+1, 1):uint()
        if offset + 2 + len > tvb:len() then return "<bin>", tvb:len() end
        return "0x" .. tvb:range(offset + 2, len):bytes():tohex(), offset + 2 + len
    end
    if b == 0xc5 then
        local len = tvb:range(offset+1, 2):uint()
        if offset + 3 + len > tvb:len() then return "<bin>", tvb:len() end
        return "0x" .. tvb:range(offset + 3, len):bytes():tohex(), offset + 3 + len
    end
    if b == 0xc6 then
        local len = tvb:range(offset+1, 4):uint()
        if offset + 5 + len > tvb:len() then return "<bin>", tvb:len() end
        return "0x" .. tvb:range(offset + 5, len):bytes():tohex(), offset + 5 + len
    end

    -- fixarray / array16 / array32
    if b >= 0x90 and b <= 0x9f then
        local n = b - 0x90
        local off = offset + 1
        local parts = {}
        for _ = 1, n do
            local v; v, off = _M.msgpack_read_any(tvb, off)
            parts[#parts + 1] = v
        end
        return "[" .. table.concat(parts, ", ") .. "]", off
    end
    if b == 0xdc then
        local n = tvb:range(offset+1, 2):uint()
        local off = offset + 3
        local parts = {}
        for _ = 1, n do
            local v; v, off = _M.msgpack_read_any(tvb, off)
            parts[#parts + 1] = v
        end
        return "[" .. table.concat(parts, ", ") .. "]", off
    end
    if b == 0xdd then
        local n = tvb:range(offset+1, 4):uint()
        local off = offset + 5
        local parts = {}
        for _ = 1, n do
            local v; v, off = _M.msgpack_read_any(tvb, off)
            parts[#parts + 1] = v
        end
        return "[" .. table.concat(parts, ", ") .. "]", off
    end

    -- fixmap / map16 / map32
    if (b >= 0x80 and b <= 0x8f) or b == 0xde or b == 0xdf then
        local n, off
        if b >= 0x80 and b <= 0x8f then
            n = b - 0x80; off = offset + 1
        elseif b == 0xde then
            n = tvb:range(offset+1, 2):uint(); off = offset + 3
        else
            n = tvb:range(offset+1, 4):uint(); off = offset + 5
        end
        local parts = {}
        for _ = 1, n do
            local k, v
            k, off = _M.msgpack_read_any(tvb, off)
            v, off = _M.msgpack_read_any(tvb, off)
            parts[#parts + 1] = k .. ":" .. v
        end
        return "{" .. table.concat(parts, ", ") .. "}", off
    end

    return string.format("<0x%02x>", b), offset + 1
end

--- Decode full MessagePack metadata and extract body_type.
--- Metadata can be either a map (keys are strings) or an array
--- (positional: [trace_id, token, client_version, body_type, ...]).
--- Returns body_type value (or nil)
function _M.decode_metadata_tree(tree, tvb, meta_offset, meta_len)
    if meta_len < 1 then return nil end
    local offset = meta_offset
    local end_off = meta_offset + meta_len
    local b = tvb:range(offset, 1):uint()

    -- Determine if metadata is a map or an array
    local is_map = false
    local is_array = false
    local count = 0

    -- fixmap 0x80-0x8f
    if b >= 0x80 and b <= 0x8f then
        is_map = true
        count = b - 0x80
        offset = offset + 1
    -- map16
    elseif b == 0xde then
        is_map = true
        count = tvb:range(offset + 1, 2):uint()
        offset = offset + 3
    -- map32
    elseif b == 0xdf then
        is_map = true
        count = tvb:range(offset + 1, 4):uint()
        offset = offset + 5
    -- fixarray 0x90-0x9f
    elseif b >= 0x90 and b <= 0x9f then
        is_array = true
        count = b - 0x90
        offset = offset + 1
    -- array16
    elseif b == 0xdc then
        is_array = true
        count = tvb:range(offset + 1, 2):uint()
        offset = offset + 3
    -- array32
    elseif b == 0xdd then
        is_array = true
        count = tvb:range(offset + 1, 4):uint()
        offset = offset + 5
    else
        -- Metadata might be a single uint value representing body_type directly
        local val, new_off = _M.msgpack_read_uint(tvb, offset)
        if val then
            tree:add(F.f_body_type, tvb:range(meta_offset, meta_len), val)
            return val
        end
        return nil
    end

    -- === Array format: positional [trace_id, token, client_version, body_type, ...] ===
    if is_array then
        local body_type_val = nil
        -- Array field names by position (per spec Section 2.2)
        local field_names = {"trace_id", "token", "client_version", "body_type"}

        for i = 1, count do
            if offset >= end_off then break end
            local elem_start = offset
            local val_str, val_end = _M.msgpack_read_any(tvb, offset)

            -- Also try reading as uint for body_type extraction
            local val_uint, _ = _M.msgpack_read_uint(tvb, offset)

            offset = val_end

            -- Add to tree with position label
            local label = field_names[i] or string.format("field[%d]", i)
            local elem_len = val_end - elem_start
            if elem_len > 0 and elem_start + elem_len <= tvb:len() then
                tree:add(F.f_md_entry, tvb:range(elem_start, elem_len),
                    label .. " = " .. val_str)
            end

            -- Position 4 (index 4) = body_type
            if i == 4 and val_uint then
                body_type_val = val_uint
            end
        end

        -- If body_type not at position 4, scan for any uint matching known opcodes
        if body_type_val == nil then
            local scan_off = meta_offset
            -- skip array header
            local hdr = tvb:range(scan_off, 1):uint()
            if hdr >= 0x90 and hdr <= 0x9f then
                scan_off = scan_off + 1
            elseif hdr == 0xdc then
                scan_off = scan_off + 3
            elseif hdr == 0xdd then
                scan_off = scan_off + 5
            end
            for i = 1, count do
                if scan_off >= end_off then break end
                local v, _ = _M.msgpack_read_uint(tvb, scan_off)
                if v and OPCODES[v] then
                    body_type_val = v
                    break
                end
                -- skip this element
                local _, skip_end = _M.msgpack_read_any(tvb, scan_off)
                scan_off = skip_end
            end
        end

        return body_type_val
    end

    -- === Map format: keys are strings ===
    local body_type_val = nil

    for i = 1, count do
        if offset >= end_off then break end
        local kv_start = offset

        -- Read key
        local key, key_end = _M.msgpack_read_string(tvb, offset)
        local key_is_int = false
        local key_int_val = nil
        if key == nil then
            local kval; kval, key_end = _M.msgpack_read_uint(tvb, offset)
            if kval then
                key = tostring(kval)
                key_is_int = true
                key_int_val = kval
            else
                local kstr; kstr, key_end = _M.msgpack_read_any(tvb, offset)
                key = kstr
            end
        end
        offset = key_end

        -- Read value
        local val_uint, _ = _M.msgpack_read_uint(tvb, offset)
        local val_str, val_end = _M.msgpack_read_any(tvb, offset)
        offset = val_end

        -- Add to tree
        local kv_range_len = val_end - kv_start
        if kv_range_len > 0 and kv_start + kv_range_len <= tvb:len() then
            tree:add(F.f_md_entry, tvb:range(kv_start, kv_range_len),
                key .. " = " .. val_str)
        end

        -- Capture body_type
        if not key_is_int then
            if key == "body_type" or key == "opcode" or key == "op"
               or key == "cmd" or key == "type" or key == "msg_type" then
                local num_val = tonumber(val_str)
                if num_val then body_type_val = num_val end
            end
        end
        if key_is_int and key_int_val == 1 and val_uint then
            if body_type_val == nil then
                body_type_val = val_uint
            end
        end
        if body_type_val == nil and val_uint and OPCODES[val_uint] then
            body_type_val = val_uint
        end
    end

    return body_type_val
end

--- Extract body_type from MessagePack metadata
function _M.extract_body_type(tvb, meta_offset, meta_len)
    if meta_len < 2 then return nil end
    local offset = meta_offset
    local b = tvb:range(offset, 1):uint()
    local map_size = 0

    -- Determine map size
    if b >= 0x80 and b <= 0x8f then
        map_size = b - 0x80
        offset = offset + 1
    elseif b == 0xde then
        map_size = tvb:range(offset + 1, 2):uint()
        offset = offset + 3
    elseif b == 0xdf then
        map_size = tvb:range(offset + 1, 4):uint()
        offset = offset + 5
    else
        return nil
    end

    -- Iterate map entries looking for "body_type"
    for _ = 1, map_size do
        if offset >= meta_offset + meta_len then break end
        local key, new_offset = _M.msgpack_read_string(tvb, offset)
        if key == nil then break end
        offset = new_offset

        if key == "body_type" then
            local val, _ = _M.msgpack_read_uint(tvb, offset)
            return val
        end
        -- skip value
        offset = _M.msgpack_skip(tvb, offset)
    end
    return nil
end

-- ============================================================
-- Governance Block Parser
-- ============================================================
function _M.parse_governance_block(tree, tvb, offset, gov_len)
    local gov_tree = tree:add(tvb:range(offset, gov_len), "Governance Extension Block (" .. gov_len .. " bytes)")
    local end_offset = offset + gov_len

    while offset < end_offset do
        if offset + 3 > tvb:len() then break end
        local tag_type = tvb:range(offset, 1):uint()
        local tag_len = tvb:range(offset + 1, 2):uint()
        local val_offset = offset + 3

        if val_offset + tag_len > tvb:len() then break end

        if tag_type == 0x01 and tag_len == 24 then
            local t = gov_tree:add(F.f_gov_tag_type, tvb:range(offset, 1)):append_text(" (Trace Context)")
            gov_tree:add(F.f_gov_trace_id, tvb:range(val_offset, 16))
            gov_tree:add(F.f_gov_span_id, tvb:range(val_offset + 16, 8))
        elseif tag_type == 0x02 then
            gov_tree:add(F.f_gov_tag_type, tvb:range(offset, 1)):append_text(" (Traffic Coloring)")
            gov_tree:add(F.f_gov_coloring, tvb:range(val_offset, tag_len))
        elseif tag_type == 0x03 and tag_len == 8 then
            gov_tree:add(F.f_gov_tag_type, tvb:range(offset, 1)):append_text(" (Method Metrics)")
            gov_tree:add(F.f_gov_queue_us, tvb:range(val_offset, 4))
            gov_tree:add(F.f_gov_exec_ms, tvb:range(val_offset + 4, 4))
        elseif tag_type == 0x04 and tag_len == 16 then
            gov_tree:add(F.f_gov_tag_type, tvb:range(offset, 1)):append_text(" (Tenant Quota Token)")
            gov_tree:add(F.f_gov_tag_val, tvb:range(val_offset, tag_len))
        else
            gov_tree:add(F.f_gov_tag_type, tvb:range(offset, 1))
            gov_tree:add(F.f_gov_tag_len, tvb:range(offset + 1, 2))
            if tag_len > 0 then
                gov_tree:add(F.f_gov_tag_val, tvb:range(val_offset, tag_len))
            end
        end

        offset = val_offset + tag_len
    end
    return end_offset
end

-- ============================================================
-- Body Parsers by OpCode
-- ============================================================

function _M.parse_handshake_request(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset >= end_off then return end
    -- client_id_len + client_id
    local cid_len = tvb:range(offset, 1):uint()
    tree:add(F.f_client_id_len, tvb:range(offset, 1))
    offset = offset + 1
    if offset + cid_len <= end_off then
        tree:add(F.f_client_id, tvb:range(offset, cid_len))
        offset = offset + cid_len
    end
    -- access_key_len + access_key
    if offset >= end_off then return end
    local ak_len = tvb:range(offset, 1):uint()
    tree:add(F.f_access_key_len, tvb:range(offset, 1))
    offset = offset + 1
    if offset + ak_len <= end_off then
        tree:add(F.f_access_key, tvb:range(offset, ak_len))
        offset = offset + ak_len
    end
    -- timestamp u64
    if offset + 8 <= end_off then
        tree:add(F.f_timestamp, tvb:range(offset, 8))
        offset = offset + 8
    end
    -- signature_len + signature
    if offset >= end_off then return end
    local sig_len = tvb:range(offset, 1):uint()
    tree:add(F.f_sig_len, tvb:range(offset, 1))
    offset = offset + 1
    if offset + sig_len <= end_off then
        tree:add(F.f_signature, tvb:range(offset, sig_len))
        offset = offset + sig_len
    end
    -- nonce_present
    if offset >= end_off then return end
    local np = tvb:range(offset, 1):uint()
    tree:add(F.f_nonce_present, tvb:range(offset, 1))
    offset = offset + 1
    if np == 1 and offset + 32 <= end_off then
        tree:add(F.f_server_nonce, tvb:range(offset, 32))
        offset = offset + 32
    end
    -- label_count + labels
    if offset >= end_off then return end
    local lc = tvb:range(offset, 1):uint()
    tree:add(F.f_label_count, tvb:range(offset, 1))
    offset = offset + 1
    for _ = 1, lc do
        if offset >= end_off then break end
        local kl = tvb:range(offset, 1):uint(); offset = offset + 1
        if offset + kl > end_off then break end
        offset = offset + kl
        if offset >= end_off then break end
        local vl = tvb:range(offset, 1):uint(); offset = offset + 1
        if offset + vl > end_off then break end
        offset = offset + vl
    end
end

function _M.parse_nonce_challenge_request(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset >= end_off then return end
    local cid_len = tvb:range(offset, 1):uint()
    tree:add(F.f_client_id_len, tvb:range(offset, 1))
    offset = offset + 1
    if offset + cid_len <= end_off then
        tree:add(F.f_client_id, tvb:range(offset, cid_len))
        offset = offset + cid_len
    end
    if offset + 8 <= end_off then
        tree:add(F.f_timestamp, tvb:range(offset, 8))
    end
end

function _M.parse_nonce_challenge_response(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    tree:add(F.f_nonce_status, tvb:range(offset, 2))
    offset = offset + 2
    if offset + 32 <= end_off then
        tree:add(F.f_server_nonce, tvb:range(offset, 32))
        offset = offset + 32
    end
    if offset + 4 <= end_off then
        tree:add(F.f_nonce_ttl, tvb:range(offset, 4))
        offset = offset + 4
    end
    if offset + 8 <= end_off then
        tree:add(F.f_server_ts, tvb:range(offset, 8))
    end
end

function _M.parse_register_instance(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local svc_len = tvb:range(offset, 2):uint()
    tree:add(F.f_svc_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + svc_len > end_off then return end
    tree:add(F.f_svc_name, tvb:range(offset, svc_len))
    offset = offset + svc_len
    if offset >= end_off then return end
    local ip_type = tvb:range(offset, 1):uint()
    tree:add(F.f_ip_type, tvb:range(offset, 1))
    offset = offset + 1
    if offset + 2 > end_off then return end
    tree:add(F.f_port, tvb:range(offset, 2))
    offset = offset + 2
    if offset >= end_off then return end
    tree:add(F.f_ephemeral, tvb:range(offset, 1))
    offset = offset + 1
    local ip_len = (ip_type == 6) and 16 or 4
    if offset + ip_len > end_off then return end
    local ip_str = _M.extract_ip(tvb:range(offset, ip_len), ip_type)
    tree:add(F.f_ip_address, tvb:range(offset, ip_len)):append_text(" (" .. ip_str .. ")")
    offset = offset + ip_len
    if offset + 4 > end_off then return end
    tree:add(F.f_weight, tvb:range(offset, 4))
end

function _M.parse_register_instance_with_meta(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    -- Base fields (same as register)
    if offset + 2 > end_off then return end
    local svc_len = tvb:range(offset, 2):uint()
    tree:add(F.f_svc_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + svc_len > end_off then return end
    tree:add(F.f_svc_name, tvb:range(offset, svc_len))
    offset = offset + svc_len
    if offset >= end_off then return end
    local ip_type = tvb:range(offset, 1):uint()
    tree:add(F.f_ip_type, tvb:range(offset, 1))
    offset = offset + 1
    if offset + 2 > end_off then return end
    tree:add(F.f_port, tvb:range(offset, 2))
    offset = offset + 2
    if offset >= end_off then return end
    tree:add(F.f_ephemeral, tvb:range(offset, 1))
    offset = offset + 1
    local ip_len = (ip_type == 6) and 16 or 4
    if offset + ip_len > end_off then return end
    tree:add(F.f_ip_address, tvb:range(offset, ip_len)):append_text(" (" .. _M.extract_ip(tvb:range(offset, ip_len), ip_type) .. ")")
    offset = offset + ip_len
    if offset + 4 > end_off then return end
    tree:add(F.f_weight, tvb:range(offset, 4))
    offset = offset + 4
    -- Metadata entries
    if offset + 2 > end_off then return end
    local mc = tvb:range(offset, 2):uint()
    tree:add(F.f_meta_count, tvb:range(offset, 2))
    offset = offset + 2
    if mc > 0 then
        local meta_tree = tree:add(tvb:range(offset, 0), "Metadata Entries")
        _M.parse_meta_entries(meta_tree, tvb, offset, mc)
    end
end

function _M.parse_deregister_instance(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local svc_len = tvb:range(offset, 2):uint()
    tree:add(F.f_svc_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + svc_len > end_off then return end
    tree:add(F.f_svc_name, tvb:range(offset, svc_len))
    offset = offset + svc_len
    if offset + 2 > end_off then return end
    local af = tvb:range(offset, 2):uint()
    tree:add(F.f_addr_family, tvb:range(offset, 2))
    offset = offset + 2
    local ip_len = (af == 0x0002) and 16 or 4
    if offset + ip_len > end_off then return end
    local ip_type = (af == 0x0002) and 6 or 4
    tree:add(F.f_ip_address, tvb:range(offset, ip_len)):append_text(" (" .. _M.extract_ip(tvb:range(offset, ip_len), ip_type) .. ")")
    offset = offset + ip_len
    if offset + 2 > end_off then return end
    tree:add(F.f_port, tvb:range(offset, 2))
end

function _M.parse_snapshot(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local svc_len = tvb:range(offset, 2):uint()
    tree:add(F.f_svc_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + svc_len > end_off then return end
    tree:add(F.f_svc_name, tvb:range(offset, svc_len))
    offset = offset + svc_len
    if offset + 8 > end_off then return end
    tree:add(F.f_topology_ver, tvb:range(offset, 8))
    offset = offset + 8
    if offset + 2 > end_off then return end
    local count = tvb:range(offset, 2):uint()
    tree:add(F.f_instance_count, tvb:range(offset, 2))
    offset = offset + 2
    if count > 0 then
        local arr_tree = tree:add(tvb:range(offset, 0), "Instance Array")
        _M.parse_instance_array(arr_tree, tvb, offset, count)
    end
end

function _M.parse_config_response(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    -- tenant
    if offset + 2 > end_off then return end
    local tl = tvb:range(offset, 2):uint()
    tree:add(F.f_tenant_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + tl > end_off then return end
    tree:add(F.f_tenant, tvb:range(offset, tl))
    offset = offset + tl
    -- group
    if offset + 2 > end_off then return end
    local gl = tvb:range(offset, 2):uint()
    tree:add(F.f_group_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + gl > end_off then return end
    tree:add(F.f_group, tvb:range(offset, gl))
    offset = offset + gl
    -- data_id
    if offset + 2 > end_off then return end
    local dl = tvb:range(offset, 2):uint()
    tree:add(F.f_data_id_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + dl > end_off then return end
    tree:add(F.f_data_id, tvb:range(offset, dl))
    offset = offset + dl
    -- md5 16 bytes
    if offset + 16 > end_off then return end
    tree:add(F.f_md5, tvb:range(offset, 16))
    offset = offset + 16
    -- total_chunks, chunk_index
    if offset + 2 > end_off then return end
    tree:add(F.f_total_chunks, tvb:range(offset, 2))
    offset = offset + 2
    if offset + 2 > end_off then return end
    tree:add(F.f_chunk_index, tvb:range(offset, 2))
    offset = offset + 2
    -- is_deleted
    if offset >= end_off then return end
    tree:add(F.f_is_deleted, tvb:range(offset, 1))
    offset = offset + 1
    -- raw_len + raw_bytes
    if offset + 4 > end_off then return end
    local rl = tvb:range(offset, 4):uint()
    tree:add(F.f_raw_len, tvb:range(offset, 4))
    offset = offset + 4
    if rl > 0 and offset + rl <= end_off then
        tree:add(F.f_raw_bytes, tvb:range(offset, rl))
    end
end

function _M.parse_config_changed_notify(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local tl = tvb:range(offset, 2):uint()
    tree:add(F.f_tenant_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + tl > end_off then return end
    tree:add(F.f_tenant, tvb:range(offset, tl))
    offset = offset + tl
    if offset + 2 > end_off then return end
    local gl = tvb:range(offset, 2):uint()
    tree:add(F.f_group_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + gl > end_off then return end
    tree:add(F.f_group, tvb:range(offset, gl))
    offset = offset + gl
    if offset + 2 > end_off then return end
    local dl = tvb:range(offset, 2):uint()
    tree:add(F.f_data_id_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + dl > end_off then return end
    tree:add(F.f_data_id, tvb:range(offset, dl))
    offset = offset + dl
    if offset + 16 > end_off then return end
    tree:add(F.f_md5, tvb:range(offset, 16))
end

function _M.parse_listen_config(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local count = tvb:range(offset, 2):uint()
    tree:add(F.f_listen_count, tvb:range(offset, 2))
    offset = offset + 2
    for i = 1, count do
        if offset >= end_off then break end
        local entry_tree = tree:add(tvb:range(offset, 0), "Listen Entry [" .. i .. "]")
        -- tenant (u8 len)
        local tl = tvb:range(offset, 1):uint()
        entry_tree:add(F.f_tenant_len8, tvb:range(offset, 1))
        offset = offset + 1
        if offset + tl > end_off then break end
        entry_tree:add(F.f_tenant, tvb:range(offset, tl))
        offset = offset + tl
        -- group (u8 len)
        if offset >= end_off then break end
        local gl = tvb:range(offset, 1):uint()
        entry_tree:add(F.f_group_len8, tvb:range(offset, 1))
        offset = offset + 1
        if offset + gl > end_off then break end
        entry_tree:add(F.f_group, tvb:range(offset, gl))
        offset = offset + gl
        -- data_id (u8 len)
        if offset >= end_off then break end
        local dl = tvb:range(offset, 1):uint()
        entry_tree:add(F.f_data_id_len8, tvb:range(offset, 1))
        offset = offset + 1
        if offset + dl > end_off then break end
        entry_tree:add(F.f_data_id, tvb:range(offset, dl))
        offset = offset + dl
        -- current_md5 16 bytes
        if offset + 16 > end_off then break end
        entry_tree:add(F.f_current_md5, tvb:range(offset, 16))
        offset = offset + 16
    end
end

function _M.parse_tenant_auth_override_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset >= end_off then return end
    local tl = tvb:range(offset, 1):uint()
    tree:add(F.f_tenant_len_u8, tvb:range(offset, 1))
    offset = offset + 1
    if offset + tl > end_off then return end
    tree:add(F.f_tenant, tvb:range(offset, tl))
    offset = offset + tl
    if offset + 2 > end_off then return end
    tree:add(F.f_policy_flags, tvb:range(offset, 2))
    offset = offset + 2
    if offset + 4 > end_off then return end
    tree:add(F.f_max_connections, tvb:range(offset, 4))
    offset = offset + 4
    if offset + 4 > end_off then return end
    tree:add(F.f_rate_limit_ops, tvb:range(offset, 4))
end

function _M.parse_tenant_auth_override_res(tree, tvb, offset, body_len)
    if body_len < 10 then return end
    tree:add(F.f_seq_number, tvb:range(offset, 4))
    tree:add(F.f_status_code, tvb:range(offset + 4, 2))
    tree:add(F.f_resp_padding, tvb:range(offset + 6, 2))
    tree:add(F.f_lease_time, tvb:range(offset + 8, 4))
end

function _M.parse_cluster_redirect(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 4 > end_off then return end
    tree:add(F.f_seq_number, tvb:range(offset, 4))
    offset = offset + 4
    if offset >= end_off then return end
    tree:add(F.f_redirect_reason, tvb:range(offset, 1))
    offset = offset + 1
    if offset + 2 > end_off then return end
    tree:add(F.f_graceful_wait, tvb:range(offset, 2))
    offset = offset + 2
    if offset >= end_off then return end
    local ip_type = tvb:range(offset, 1):uint()
    tree:add(F.f_target_ip_type, tvb:range(offset, 1))
    offset = offset + 1
    if offset + 2 > end_off then return end
    tree:add(F.f_target_port, tvb:range(offset, 2))
    offset = offset + 2
    local ip_len = (ip_type == 6) and 16 or 4
    if offset + ip_len > end_off then return end
    tree:add(F.f_target_ip, tvb:range(offset, ip_len)):append_text(" (" .. _M.extract_ip(tvb:range(offset, ip_len), ip_type) .. ")")
end

function _M.parse_raft_append_entries_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 8 > end_off then return end
    tree:add(F.f_term, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_leader_id, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_prev_log_idx, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_prev_log_term, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_leader_commit, tvb:range(offset, 8)); offset = offset + 8
    if offset + 2 > end_off then return end
    local ec = tvb:range(offset, 2):uint()
    tree:add(F.f_entry_count, tvb:range(offset, 2)); offset = offset + 2
    for i = 1, ec do
        if offset + 8 > end_off then break end
        local e_tree = tree:add(tvb:range(offset, 0), "Raft Log Entry [" .. i .. "]")
        local start = offset
        e_tree:add(F.f_entry_index, tvb:range(offset, 8)); offset = offset + 8
        if offset + 8 > end_off then break end
        e_tree:add(F.f_entry_term, tvb:range(offset, 8)); offset = offset + 8
        if offset + 2 > end_off then break end
        local iop = tvb:range(offset, 2):uint()
        e_tree:add(F.f_inner_opcode, tvb:range(offset, 2)):append_text(" (" .. (OPCODES[iop] or "Unknown") .. ")")
        offset = offset + 2
        if offset + 4 > end_off then break end
        local pl = tvb:range(offset, 4):uint()
        e_tree:add(F.f_payload_len_raft, tvb:range(offset, 4)); offset = offset + 4
        if pl > 0 and offset + pl <= end_off then
            e_tree:add(F.f_cmd_payload, tvb:range(offset, pl))
            offset = offset + pl
        end
        e_tree:set_len(offset - start)
    end
end

function _M.parse_raft_append_entries_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 8 > end_off then return end
    tree:add(F.f_term, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_match_log_idx, tvb:range(offset, 8)); offset = offset + 8
    if offset >= end_off then return end
    tree:add(F.f_success, tvb:range(offset, 1)):append_text(tvb:range(offset, 1):uint() == 1 and " (Appended)" or " (Failed)")
    offset = offset + 1
    if offset + 3 <= end_off then
        tree:add(F.f_raft_padding, tvb:range(offset, 3))
    end
end

function _M.parse_raft_request_vote_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 8 > end_off then return end
    tree:add(F.f_term, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_candidate_id, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_last_log_idx, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_last_log_term, tvb:range(offset, 8))
end

function _M.parse_raft_request_vote_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 8 > end_off then return end
    tree:add(F.f_term, tvb:range(offset, 8)); offset = offset + 8
    if offset >= end_off then return end
    tree:add(F.f_vote_granted, tvb:range(offset, 1)):append_text(tvb:range(offset, 1):uint() == 1 and " (Granted)" or " (Denied)")
    offset = offset + 1
    if offset + 7 <= end_off then
        tree:add(F.f_raft_padding, tvb:range(offset, 7))
    end
end

function _M.parse_distro_sync(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 8 > end_off then return end
    tree:add(F.f_source_server_id, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_shard_version, tvb:range(offset, 8)); offset = offset + 8
    if offset >= end_off then return end
    local st = tvb:range(offset, 1):uint()
    local st_names = {[0]="Register",[1]="Deregister",[2]="Renew/LoadSync",[3]="OutlierVote"}
    tree:add(F.f_sync_type, tvb:range(offset, 1)):append_text(" (" .. (st_names[st] or "Unknown") .. ")")
    offset = offset + 1

    if st == 0x03 then
        -- Outlier vote variant
        if offset + 8 > end_off then return end
        tree:add(F.f_node_id, tvb:range(offset, 8)):set_text("Suspect Server ID")
        offset = offset + 8
        if offset + 4 > end_off then return end
        tree:add(F.f_metrics_pack, tvb:range(offset, 4)):set_text("Error Rate Pack")
        return
    end

    -- service_key (u16 len + string)
    if offset + 2 > end_off then return end
    local sk_len = tvb:range(offset, 2):uint()
    tree:add(F.f_service_key_len, tvb:range(offset, 2))
    offset = offset + 2
    if offset + sk_len > end_off then return end
    tree:add(F.f_service_key, tvb:range(offset, sk_len))
    offset = offset + sk_len
    -- active_connections
    if offset + 4 > end_off then return end
    tree:add(F.f_active_conns, tvb:range(offset, 4))
    offset = offset + 4
    -- metrics_pack
    if offset + 4 > end_off then return end
    local mp_tree = tree:add(F.f_metrics_pack, tvb:range(offset, 4))
    _M.parse_metrics_pack(mp_tree, tvb:range(offset, 4))
    offset = offset + 4
    -- real_ip_type
    if offset >= end_off then return end
    local ip_type = tvb:range(offset, 1):uint()
    tree:add(F.f_real_ip_type, tvb:range(offset, 1))
    offset = offset + 1
    -- real_port
    if offset + 2 > end_off then return end
    tree:add(F.f_real_port, tvb:range(offset, 2))
    offset = offset + 2
    -- instance_data (remaining)
    if offset < end_off then
        tree:add(F.f_instance_data, tvb:range(offset, end_off - offset))
    end
end

function _M.parse_cluster_load_report(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 8 > end_off then return end
    tree:add(F.f_node_id, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_load_term, tvb:range(offset, 8)); offset = offset + 8
    if offset + 4 > end_off then return end
    tree:add(F.f_load_conns, tvb:range(offset, 4)); offset = offset + 4
    if offset + 4 > end_off then return end
    local mp_tree = tree:add(F.f_load_metrics, tvb:range(offset, 4))
    _M.parse_metrics_pack(mp_tree, tvb:range(offset, 4))
    offset = offset + 4
    -- Extended fields (FIP extension): real_ip_type, real_port, real_ip
    if offset >= end_off then return end
    local ip_type = tvb:range(offset, 1):uint()
    tree:add(F.f_real_ip_type, tvb:range(offset, 1))
    offset = offset + 1
    if offset + 2 > end_off then return end
    tree:add(F.f_real_port, tvb:range(offset, 2))
    offset = offset + 2
    local ip_len = (ip_type == 6) and 16 or 4
    if offset + ip_len <= end_off then
        tree:add(F.f_ip_address, tvb:range(offset, ip_len)):append_text(" (" .. _M.extract_ip(tvb:range(offset, ip_len), ip_type) .. ")")
    end
end

function _M.parse_leader_redirect(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 8 > end_off then return end
    tree:add(F.f_leader_term, tvb:range(offset, 8)); offset = offset + 8
    if offset + 4 > end_off then return end
    tree:add(F.f_target_stream, tvb:range(offset, 4)); offset = offset + 4
    if offset >= end_off then return end
    tree:add(F.f_redirect_reason, tvb:range(offset, 1)); offset = offset + 1
    if offset >= end_off then return end
    local ip_type = tvb:range(offset, 1):uint()
    tree:add(F.f_dest_ip_type, tvb:range(offset, 1)); offset = offset + 1
    if offset + 2 > end_off then return end
    tree:add(F.f_dest_port, tvb:range(offset, 2)); offset = offset + 2
    local ip_len = (ip_type == 6) and 16 or 4
    if offset + ip_len <= end_off then
        tree:add(F.f_dest_ip, tvb:range(offset, ip_len)):append_text(" (" .. _M.extract_ip(tvb:range(offset, ip_len), ip_type) .. ")")
        offset = offset + ip_len
    end
    -- graceful_wait_ms (u32) - v07 extension
    if offset + 4 <= end_off then
        tree:add(F.f_migration_wait, tvb:range(offset, 4))
    end
end

function _M.parse_shutdown_notice(tree, tvb, offset, body_len)
    if body_len >= 4 then
        tree:add(F.f_shutdown_delay, tvb:range(offset, 4))
    end
end

function _M.parse_filter_discovery_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    -- tenant (u16 len)
    if offset + 2 > end_off then return end
    local tl = tvb:range(offset, 2):uint()
    tree:add(F.f_tenant_len, tvb:range(offset, 2)); offset = offset + 2
    if offset + tl > end_off then return end
    tree:add(F.f_tenant, tvb:range(offset, tl)); offset = offset + tl
    -- service_name (u16 len)
    if offset + 2 > end_off then return end
    local sl = tvb:range(offset, 2):uint()
    tree:add(F.f_svc_len, tvb:range(offset, 2)); offset = offset + 2
    if offset + sl > end_off then return end
    tree:add(F.f_svc_name, tvb:range(offset, sl)); offset = offset + sl
    -- filter_expr (u16 len)
    if offset + 2 > end_off then return end
    local fl = tvb:range(offset, 2):uint()
    tree:add(F.f_filter_expr_len, tvb:range(offset, 2)); offset = offset + 2
    if fl > 0 and offset + fl <= end_off then
        tree:add(F.f_filter_expr, tvb:range(offset, fl))
        offset = offset + fl
    end
    -- include_metadata
    if offset < end_off then
        tree:add(F.f_include_metadata, tvb:range(offset, 1))
    end
end

function _M.parse_filter_discovery_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local sl = tvb:range(offset, 2):uint()
    tree:add(F.f_svc_len, tvb:range(offset, 2)); offset = offset + 2
    if offset + sl > end_off then return end
    tree:add(F.f_svc_name, tvb:range(offset, sl)); offset = offset + sl
    if offset + 8 > end_off then return end
    tree:add(F.f_topology_ver, tvb:range(offset, 8)); offset = offset + 8
    if offset + 2 > end_off then return end
    tree:add(F.f_total_count, tvb:range(offset, 2)); offset = offset + 2
    if offset + 2 > end_off then return end
    local ic = tvb:range(offset, 2):uint()
    tree:add(F.f_instance_count, tvb:range(offset, 2)); offset = offset + 2
    -- instance array with metadata
    for i = 1, ic do
        if offset >= end_off then break end
        local inst_tree = tree:add(tvb:range(offset, 0), "Instance [" .. i .. "]")
        local start = offset
        local ip_type = tvb:range(offset, 1):uint()
        inst_tree:add(F.f_ip_type, tvb:range(offset, 1)); offset = offset + 1
        if offset + 2 > end_off then break end
        inst_tree:add(F.f_port, tvb:range(offset, 2)); offset = offset + 2
        if offset >= end_off then break end
        inst_tree:add(F.f_is_healthy, tvb:range(offset, 1)); offset = offset + 1
        local ip_len = (ip_type == 6) and 16 or 4
        if offset + ip_len > end_off then break end
        inst_tree:add(F.f_ip_address, tvb:range(offset, ip_len)):append_text(" (" .. _M.extract_ip(tvb:range(offset, ip_len), ip_type) .. ")")
        offset = offset + ip_len
        if offset + 4 > end_off then break end
        inst_tree:add(F.f_weight, tvb:range(offset, 4)); offset = offset + 4
        if offset + 4 > end_off then break end
        local mp_t = inst_tree:add(F.f_metrics_pack, tvb:range(offset, 4))
        _M.parse_metrics_pack(mp_t, tvb:range(offset, 4))
        offset = offset + 4
        if offset + 8 > end_off then break end
        inst_tree:add(F.f_metadata_hash, tvb:range(offset, 8)); offset = offset + 8
        -- meta_count + entries
        if offset + 2 > end_off then break end
        local mc = tvb:range(offset, 2):uint()
        inst_tree:add(F.f_meta_count, tvb:range(offset, 2)); offset = offset + 2
        if mc > 0 then
            local mt = inst_tree:add(tvb:range(offset, 0), "Metadata")
            offset = _M.parse_meta_entries(mt, tvb, offset, mc)
        end
        inst_tree:set_len(offset - start)
    end
end

function _M.parse_register_meta_response(tree, tvb, offset, body_len)
    if body_len >= 16 then
        tree:add(F.f_topology_ver, tvb:range(offset, 8))
        tree:add(F.f_metadata_hash, tvb:range(offset + 8, 8))
    end
end

-- Admin tenant management parsers
function _M.parse_admin_create_tenant_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local tl = tvb:range(offset, 2):uint()
    tree:add(F.f_tenant_len, tvb:range(offset, 2)); offset = offset + 2
    if offset + tl > end_off then return end
    tree:add(F.f_tenant, tvb:range(offset, tl)); offset = offset + tl
    if offset + 2 > end_off then return end
    tree:add(F.f_policy_flags, tvb:range(offset, 2)); offset = offset + 2
    if offset + 4 > end_off then return end
    tree:add(F.f_max_connections, tvb:range(offset, 4)); offset = offset + 4
    if offset + 4 > end_off then return end
    tree:add(F.f_rate_limit_ops, tvb:range(offset, 4)); offset = offset + 4
    if offset + 8 > end_off then return end
    tree:add(F.f_lease_duration, tvb:range(offset, 8))
end

function _M.parse_admin_status_res(tree, tvb, offset, body_len)
    if body_len >= 2 then
        tree:add(F.f_status_code, tvb:range(offset, 2))
    end
end

function _M.parse_admin_delete_tenant_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local tl = tvb:range(offset, 2):uint()
    tree:add(F.f_tenant_len, tvb:range(offset, 2)); offset = offset + 2
    if offset + tl > end_off then return end
    tree:add(F.f_tenant, tvb:range(offset, tl)); offset = offset + tl
    if offset >= end_off then return end
    tree:add(F.f_force, tvb:range(offset, 1))
end

function _M.parse_admin_get_stats_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local tl = tvb:range(offset, 2):uint()
    tree:add(F.f_tenant_len, tvb:range(offset, 2)); offset = offset + 2
    if offset + tl > end_off then return end
    tree:add(F.f_tenant, tvb:range(offset, tl))
end

function _M.parse_admin_get_stats_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset >= end_off then return end
    tree:add(F.f_found, tvb:range(offset, 1)); offset = offset + 1
    if offset + 4 > end_off then return end
    tree:add(F.f_active_conns, tvb:range(offset, 4)); offset = offset + 4
    if offset + 2 > end_off then return end
    tree:add(F.f_reg_services, tvb:range(offset, 2)); offset = offset + 2
    if offset + 4 > end_off then return end
    tree:add(F.f_reg_instances, tvb:range(offset, 4)); offset = offset + 4
    if offset + 2 > end_off then return end
    tree:add(F.f_credential_count, tvb:range(offset, 2)); offset = offset + 2
    if offset + 4 > end_off then return end
    tree:add(F.f_config_count, tvb:range(offset, 4))
end

-- Helper: read u16-len string and add field
function _M.read_string_field(tree, tvb, offset, end_off, len_field, str_field)
    if offset + 2 > end_off then return offset end
    local slen = tvb:range(offset, 2):uint()
    tree:add(len_field, tvb:range(offset, 2)); offset = offset + 2
    if offset + slen > end_off then return offset end
    tree:add(str_field, tvb:range(offset, slen)); offset = offset + slen
    return offset
end

-- 0x0401: AdminListServicesReq = tenant(u16+len)
function _M.parse_admin_list_services_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    _M.read_string_field(tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
end

-- 0x0402: AdminListServicesRes = count(u16) + [name(u16+len)]...
function _M.parse_admin_list_services_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local count = tvb:range(offset, 2):uint()
    tree:add(F.f_service_count, tvb:range(offset, 2)); offset = offset + 2
    for i = 1, count do
        if offset + 2 > end_off then break end
        local slen = tvb:range(offset, 2):uint()
        offset = offset + 2
        if offset + slen > end_off then break end
        tree:add(F.f_svc_name, tvb:range(offset, slen)):set_text("Service [" .. i .. "]: " .. tvb:range(offset, slen):string())
        offset = offset + slen
    end
end

-- 0x0403: AdminPutConfigReq = tenant + group + data_id + content_len(u32) + content
function _M.parse_admin_put_config_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_group_len, F.f_group)
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_data_id_len, F.f_data_id)
    if offset + 4 > end_off then return end
    local clen = tvb:range(offset, 4):uint()
    tree:add(F.f_content_len, tvb:range(offset, 4)); offset = offset + 4
    if clen > 0 and offset + clen <= end_off then
        tree:add(F.f_content, tvb:range(offset, clen))
    end
end

-- 0x0404/0x0406/0x040C: AdminSuccessResponse = success(u8)
function _M.parse_admin_success_res(tree, tvb, offset, body_len)
    if body_len >= 1 then
        tree:add(F.f_admin_success, tvb:range(offset, 1)):append_text(tvb:range(offset, 1):uint() == 1 and " (OK)" or " (Failed)")
    end
end

-- 0x0405: AdminMigrationReq = source_node_id(u64) + target_node_id(u64) + stream_id(u32) + graceful_wait_ms(u32)
function _M.parse_admin_migration_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 8 > end_off then return end
    tree:add(F.f_source_node_id, tvb:range(offset, 8)); offset = offset + 8
    if offset + 8 > end_off then return end
    tree:add(F.f_target_node_id, tvb:range(offset, 8)); offset = offset + 8
    if offset + 4 > end_off then return end
    tree:add(F.f_migration_stream, tvb:range(offset, 4)); offset = offset + 4
    if offset + 4 > end_off then return end
    tree:add(F.f_migration_wait, tvb:range(offset, 4))
end

-- 0x0408: AdminListTenantsRes = count(u16) + [AdminTenantItem]...
function _M.parse_admin_list_tenants_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local count = tvb:range(offset, 2):uint()
    tree:add(F.f_tenant_count, tvb:range(offset, 2)); offset = offset + 2
    for i = 1, count do
        if offset >= end_off then break end
        local item_tree = tree:add(tvb:range(offset, 0), "Tenant [" .. i .. "]")
        local start = offset
        offset = _M.read_string_field(item_tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
        if offset + 2 > end_off then break end
        item_tree:add(F.f_policy_flags, tvb:range(offset, 2)); offset = offset + 2
        if offset + 4 > end_off then break end
        item_tree:add(F.f_max_connections, tvb:range(offset, 4)); offset = offset + 4
        if offset + 4 > end_off then break end
        item_tree:add(F.f_rate_limit_ops, tvb:range(offset, 4)); offset = offset + 4
        if offset + 8 > end_off then break end
        item_tree:add(F.f_lease_expiry, tvb:range(offset, 8)); offset = offset + 8
        item_tree:set_len(offset - start)
    end
end

-- 0x0409: AdminListConfigsReq = tenant(u16+len) + group(u16+len)
function _M.parse_admin_list_configs_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
    _M.read_string_field(tree, tvb, offset, end_off, F.f_group_len, F.f_group)
end

-- 0x040A: AdminListConfigsRes = count(u16) + [AdminConfigItem]...
function _M.parse_admin_list_configs_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local count = tvb:range(offset, 2):uint()
    tree:add(F.f_config_count, tvb:range(offset, 2)); offset = offset + 2
    for i = 1, count do
        if offset >= end_off then break end
        local item_tree = tree:add(tvb:range(offset, 0), "Config [" .. i .. "]")
        local start = offset
        offset = _M.read_string_field(item_tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
        offset = _M.read_string_field(item_tree, tvb, offset, end_off, F.f_group_len, F.f_group)
        offset = _M.read_string_field(item_tree, tvb, offset, end_off, F.f_data_id_len, F.f_data_id)
        if offset + 16 > end_off then break end
        item_tree:add(F.f_md5, tvb:range(offset, 16)); offset = offset + 16
        if offset >= end_off then break end
        item_tree:add(F.f_is_deleted, tvb:range(offset, 1)); offset = offset + 1
        item_tree:set_len(offset - start)
    end
end

-- 0x040B: AdminDeleteConfigReq = tenant + group + data_id
function _M.parse_admin_delete_config_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_group_len, F.f_group)
    _M.read_string_field(tree, tvb, offset, end_off, F.f_data_id_len, F.f_data_id)
end

-- 0x040D: AdminGetTenantPolicyReq = tenant(u16+len)
function _M.parse_admin_get_tenant_policy_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    _M.read_string_field(tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
end

-- 0x040E: AdminGetTenantPolicyRes = found(u8)+policy_flags(u16)+max_connections(u32)+rate_limit_ops(u32)+lease_expiry_ms(u64)
function _M.parse_admin_get_tenant_policy_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset >= end_off then return end
    tree:add(F.f_found, tvb:range(offset, 1)); offset = offset + 1
    if offset + 2 > end_off then return end
    tree:add(F.f_policy_flags, tvb:range(offset, 2)); offset = offset + 2
    if offset + 4 > end_off then return end
    tree:add(F.f_max_connections, tvb:range(offset, 4)); offset = offset + 4
    if offset + 4 > end_off then return end
    tree:add(F.f_rate_limit_ops, tvb:range(offset, 4)); offset = offset + 4
    if offset + 8 > end_off then return end
    tree:add(F.f_lease_expiry, tvb:range(offset, 8))
end

-- 0x0410: AdminGetGovernanceStateRes
function _M.parse_admin_governance_state_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    -- Circuit breakers
    if offset + 2 > end_off then return end
    local cb_count = tvb:range(offset, 2):uint()
    tree:add(F.f_cb_count, tvb:range(offset, 2)); offset = offset + 2
    for i = 1, cb_count do
        if offset >= end_off then break end
        local cb_tree = tree:add(tvb:range(offset, 0), "CircuitBreaker [" .. i .. "]")
        local start = offset
        offset = _M.read_string_field(cb_tree, tvb, offset, end_off, F.f_service_key_len, F.f_service_key)
        if offset >= end_off then break end
        local state_names = {[0]="Closed",[1]="Open",[2]="HalfOpen"}
        local st = tvb:range(offset, 1):uint()
        cb_tree:add(F.f_cb_state, tvb:range(offset, 1)):append_text(" (" .. (state_names[st] or "Unknown") .. ")"); offset = offset + 1
        if offset + 2 > end_off then break end
        cb_tree:add(F.f_cb_error_rate, tvb:range(offset, 2)); offset = offset + 2
        if offset + 2 > end_off then break end
        cb_tree:add(F.f_cb_threshold, tvb:range(offset, 2)); offset = offset + 2
        if offset + 8 > end_off then break end
        cb_tree:add(F.f_cb_opened_at, tvb:range(offset, 8)); offset = offset + 8
        cb_tree:set_len(offset - start)
    end
    -- Coloring rules
    if offset + 2 > end_off then return end
    local color_count = tvb:range(offset, 2):uint()
    tree:add(F.f_coloring_count, tvb:range(offset, 2)); offset = offset + 2
    for i = 1, color_count do
        if offset >= end_off then break end
        local cr_tree = tree:add(tvb:range(offset, 0), "ColoringRule [" .. i .. "]")
        local start = offset
        offset = _M.read_string_field(cr_tree, tvb, offset, end_off, F.f_filter_expr_len, F.f_coloring_tag)
        if offset >= end_off then break end
        local tc = tvb:range(offset, 1):uint()
        cr_tree:add(F.f_coloring_target_count, tvb:range(offset, 1)); offset = offset + 1
        for _ = 1, tc do
            if offset + 2 > end_off then break end
            local tl = tvb:range(offset, 2):uint(); offset = offset + 2
            if offset + tl > end_off then break end
            cr_tree:add(F.f_svc_name, tvb:range(offset, tl)):set_text("Target: " .. tvb:range(offset, tl):string())
            offset = offset + tl
        end
        cr_tree:set_len(offset - start)
    end
    -- Outlier votes
    if offset + 2 > end_off then return end
    local ov_count = tvb:range(offset, 2):uint()
    tree:add(F.f_outlier_count, tvb:range(offset, 2)); offset = offset + 2
    for i = 1, ov_count do
        if offset + 8 > end_off then break end
        local ov_tree = tree:add(tvb:range(offset, 0), "OutlierVote [" .. i .. "]")
        local start = offset
        ov_tree:add(F.f_suspect_node_id, tvb:range(offset, 8)); offset = offset + 8
        if offset >= end_off then break end
        local vc = tvb:range(offset, 1):uint()
        ov_tree:add(F.f_voter_count, tvb:range(offset, 1)); offset = offset + 1
        for _ = 1, vc do
            if offset + 8 > end_off then break end
            ov_tree:add(F.f_node_id, tvb:range(offset, 8)):set_text("Voter ID"); offset = offset + 8
        end
        ov_tree:set_len(offset - start)
    end
    -- outlier_threshold
    if offset + 2 <= end_off then
        tree:add(F.f_outlier_threshold, tvb:range(offset, 2))
    end
end

-- 0x0419: AdminCreateCredentialReq = client_id + secret + tenant + node_type (all u16+len)
function _M.parse_admin_create_credential_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_client_id_len16, F.f_client_id_str)
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_secret_len, F.f_secret)
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
    _M.read_string_field(tree, tvb, offset, end_off, F.f_node_type_len, F.f_node_type)
end

-- 0x041B: AdminUpdateCredentialReq = client_id + has_secret(u8)+[secret] + has_tenant(u8)+[tenant] + has_node_type(u8)+[node_type] + has_enabled(u8)+[enabled(u8)]
function _M.parse_admin_update_credential_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_client_id_len16, F.f_client_id_str)
    -- has_secret
    if offset >= end_off then return end
    local hs = tvb:range(offset, 1):uint()
    tree:add(F.f_has_field, tvb:range(offset, 1)):set_text("has_secret: " .. hs); offset = offset + 1
    if hs == 1 then
        offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_secret_len, F.f_secret)
    end
    -- has_tenant
    if offset >= end_off then return end
    local ht = tvb:range(offset, 1):uint()
    tree:add(F.f_has_field, tvb:range(offset, 1)):set_text("has_tenant: " .. ht); offset = offset + 1
    if ht == 1 then
        offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
    end
    -- has_node_type
    if offset >= end_off then return end
    local hn = tvb:range(offset, 1):uint()
    tree:add(F.f_has_field, tvb:range(offset, 1)):set_text("has_node_type: " .. hn); offset = offset + 1
    if hn == 1 then
        offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_node_type_len, F.f_node_type)
    end
    -- has_enabled
    if offset >= end_off then return end
    local he = tvb:range(offset, 1):uint()
    tree:add(F.f_has_field, tvb:range(offset, 1)):set_text("has_enabled: " .. he); offset = offset + 1
    if he == 1 and offset < end_off then
        tree:add(F.f_enabled, tvb:range(offset, 1))
    end
end

-- 0x041D: AdminDeleteCredentialReq = client_id(u16+len)
function _M.parse_admin_delete_credential_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    _M.read_string_field(tree, tvb, offset, end_off, F.f_client_id_len16, F.f_client_id_str)
end

-- 0x041F: AdminListCredentialsReq = tenant_filter(u16+len)
function _M.parse_admin_list_credentials_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    _M.read_string_field(tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
end

-- 0x0420: AdminListCredentialsRes = count(u16) + items[client_id+tenant+node_type+enabled(u8)+created_at(u64)]
function _M.parse_admin_list_credentials_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local count = tvb:range(offset, 2):uint()
    tree:add(F.f_credential_count, tvb:range(offset, 2)); offset = offset + 2
    for i = 1, count do
        if offset >= end_off then break end
        local item_tree = tree:add(tvb:range(offset, 0), "Credential [" .. i .. "]")
        local start = offset
        offset = _M.read_string_field(item_tree, tvb, offset, end_off, F.f_client_id_len16, F.f_client_id_str)
        offset = _M.read_string_field(item_tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
        offset = _M.read_string_field(item_tree, tvb, offset, end_off, F.f_node_type_len, F.f_node_type)
        if offset >= end_off then break end
        item_tree:add(F.f_enabled, tvb:range(offset, 1)); offset = offset + 1
        if offset + 8 > end_off then break end
        item_tree:add(F.f_created_at, tvb:range(offset, 8)); offset = offset + 8
        item_tree:set_len(offset - start)
    end
end

-- 0x0421: AdminQueryConfigListenersReq = tenant + group + data_id
function _M.parse_admin_query_listeners_req(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_tenant_len, F.f_tenant)
    offset = _M.read_string_field(tree, tvb, offset, end_off, F.f_group_len, F.f_group)
    _M.read_string_field(tree, tvb, offset, end_off, F.f_data_id_len, F.f_data_id)
end

-- 0x0422: AdminQueryConfigListenersRes = count(u16) + items[client_id+peer_addr+current_md5(16)+registered_at(u64)]
function _M.parse_admin_query_listeners_res(tree, tvb, offset, body_len)
    local end_off = offset + body_len
    if offset + 2 > end_off then return end
    local count = tvb:range(offset, 2):uint()
    tree:add(F.f_listener_count, tvb:range(offset, 2)); offset = offset + 2
    for i = 1, count do
        if offset >= end_off then break end
        local item_tree = tree:add(tvb:range(offset, 0), "Listener [" .. i .. "]")
        local start = offset
        offset = _M.read_string_field(item_tree, tvb, offset, end_off, F.f_client_id_len16, F.f_client_id_str)
        offset = _M.read_string_field(item_tree, tvb, offset, end_off, F.f_peer_addr_len, F.f_peer_addr)
        if offset + 16 > end_off then break end
        item_tree:add(F.f_current_md5, tvb:range(offset, 16)); offset = offset + 16
        if offset + 8 > end_off then break end
        item_tree:add(F.f_registered_at, tvb:range(offset, 8)); offset = offset + 8
        item_tree:set_len(offset - start)
    end
end

-- ============================================================
-- Main Dissector (with TCP reassembly support)
-- ============================================================

-- Dissect a single HMMP frame starting at 'offset' in the tvb.
-- Returns number of bytes consumed, or negative number indicating
-- how many more bytes are needed for desegmentation.
local function dissect_one_frame(tvb, pinfo, tree, offset)
    local tvb_len = tvb:len()
    local remaining = tvb_len - offset

    -- Need at least 16 bytes for the fixed header
    if remaining < 16 then
        return -(16 - remaining)
    end

    -- Validate magic
    local magic = tvb:range(offset, 2):uint()
    if magic ~= MAGIC then return 0 end

    -- Read payload_length from header to determine full frame size
    local payload_len = tvb:range(offset + 8, 4):uint()
    local frame_len = 16 + payload_len  -- fixed header + payload

    -- Check if we have enough data for the full frame
    if remaining < frame_len then
        -- Request desegmentation: need more bytes
        return -(frame_len - remaining)
    end

    pinfo.cols.protocol = "HMMP"

    local subtree = tree:add(hmmp, tvb:range(offset, frame_len), "HMMP Frame")

    -- === Fixed Header (16 bytes) ===
    local base = offset  -- frame start offset in tvb
    local hdr_tree = subtree:add(tvb:range(base, 16), "Fixed Header")
    hdr_tree:add(F.f_magic, tvb:range(base, 2))
    hdr_tree:add(F.f_version, tvb:range(base + 2, 1))

    local flags_byte = tvb:range(base + 3, 1):uint()
    local flags_tree = hdr_tree:add(F.f_flags, tvb:range(base + 3, 1))
    flags_tree:add(F.f_flag_request, tvb:range(base + 3, 1))
    flags_tree:add(F.f_flag_compression, tvb:range(base + 3, 1))
    flags_tree:add(F.f_flag_backpressure, tvb:range(base + 3, 1))
    flags_tree:add(F.f_flag_redirect, tvb:range(base + 3, 1))
    flags_tree:add(F.f_flag_encrypted, tvb:range(base + 3, 1))
    flags_tree:add(F.f_flag_probing, tvb:range(base + 3, 1))
    flags_tree:add(F.f_flag_governance, tvb:range(base + 3, 1))

    local stream_id = tvb:range(base + 4, 4):uint()
    hdr_tree:add(F.f_stream_id, tvb:range(base + 4, 4))
    hdr_tree:add(F.f_payload_len, tvb:range(base + 8, 4))
    hdr_tree:add(F.f_padding, tvb:range(base + 12, 4))

    -- Direction indicator in info column
    local is_request = bit32.band(flags_byte, FLAG_REQUEST) ~= 0

    local cur = base + 16  -- current parse position
    local frame_end = base + frame_len

    -- === Governance Extension Block (if flag 0x80 set) ===
    if bit32.band(flags_byte, FLAG_GOVERNANCE) ~= 0 then
        if cur + 4 > frame_end then return frame_len end
        local gov_len = tvb:range(cur, 4):uint()
        subtree:add(F.f_gov_len, tvb:range(cur, 4))
        cur = cur + 4
        if gov_len > 0 and cur + gov_len <= frame_end then
            _M.parse_governance_block(subtree, tvb, cur, gov_len)
            cur = cur + gov_len
        end
    end

    -- === Two-Tier Payload ===
    if cur + 2 > frame_end then return frame_len end

    -- Metadata Length (2 bytes) defines the boundary of the MessagePack metadata block
    local meta_len = tvb:range(cur, 2):uint()
    subtree:add(F.f_meta_len, tvb:range(cur, 2))
    cur = cur + 2

    -- Metadata area (MessagePack serialized, contains 'body_type' key)
    local body_type = nil
    if meta_len > 0 and cur + meta_len <= frame_end then
        local meta_tree = subtree:add(tvb:range(cur, meta_len), "Metadata (MessagePack)")
        body_type = _M.decode_metadata_tree(meta_tree, tvb, cur, meta_len)

        if body_type then
            local opcode_name = OPCODES[body_type] or string.format("Unknown (0x%04X)", body_type)
            meta_tree:add(F.f_body_type, tvb:range(cur, meta_len), body_type)
            meta_tree:add(F.f_body_type_name, tvb:range(cur, meta_len), opcode_name)

            -- Update info column
            local dir_str = is_request and "Req" or "Res"
            if stream_id == 0 then dir_str = "Notify" end
            pinfo.cols.info = string.format("HMMP %s [%s] Stream=%d",
                opcode_name, dir_str, stream_id)
        else
            -- body_type not found in metadata, show raw metadata for debugging
            meta_tree:add(F.f_meta_raw, tvb:range(cur, meta_len)):append_text(" [body_type not found]")
        end
        cur = cur + meta_len
    elseif meta_len > 0 then
        -- metadata extends beyond frame boundary
        subtree:add(F.f_meta_raw, tvb:range(cur, frame_end - cur)):append_text(" [truncated]")
        return frame_len
    end

    -- === Body Area ===
    local body_available = frame_end - cur
    if body_available <= 0 then return frame_len end

    -- Handle encrypted body
    if bit32.band(flags_byte, FLAG_ENCRYPTED) ~= 0 then
        local enc_tree = subtree:add(tvb:range(cur, body_available), "Encrypted Body")
        if body_available >= 1 then
            local iv_len = tvb:range(cur, 1):uint()
            enc_tree:add(F.f_enc_iv_len, tvb:range(cur, 1))
            local eoff = cur + 1
            if eoff + iv_len <= frame_end then
                enc_tree:add(F.f_enc_iv, tvb:range(eoff, iv_len))
                eoff = eoff + iv_len
            end
            if eoff + 4 <= frame_end then
                local ct_len = tvb:range(eoff, 4):uint()
                enc_tree:add(F.f_enc_ct_len, tvb:range(eoff, 4))
                eoff = eoff + 4
                if ct_len > 0 and eoff + ct_len <= frame_end then
                    enc_tree:add(F.f_enc_ct, tvb:range(eoff, ct_len))
                end
            end
        end
        return frame_len
    end

    -- Dispatch body parser based on OpCode
    if body_type == nil then
        -- No body_type found, show raw body
        if body_available > 0 then
            subtree:add(F.f_raw_bytes, tvb:range(cur, body_available)):set_text("Body (raw)")
        end
        return frame_len
    end

    local body_tree = subtree:add(tvb:range(cur, body_available), "Body Area (" .. (OPCODES[body_type] or "Unknown") .. ")")

    if body_type == 0x0001 then
        _M.parse_handshake_request(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0007 then
        _M.parse_nonce_challenge_request(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0008 then
        _M.parse_nonce_challenge_response(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0003 then
        -- HeartbeatPing: may contain metrics_pack (4 bytes)
        if body_available >= 4 then
            local mp_tree = body_tree:add(F.f_metrics_pack, tvb:range(cur, 4))
            _M.parse_metrics_pack(mp_tree, tvb:range(cur, 4))
        end
    elseif body_type == 0x0005 then
        _M.parse_cluster_redirect(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0006 then
        _M.parse_shutdown_notice(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0101 then
        _M.parse_register_instance(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0102 then
        -- RegisterInstanceResponse: topology_version(u64)
        if body_available >= 8 then
            body_tree:add(F.f_topology_ver, tvb:range(cur, 8))
        end
    elseif body_type == 0x0103 then
        _M.parse_deregister_instance(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0104 then
        -- DeregisterInstanceResponse: success(u8) + topology_version(u64)
        if body_available >= 1 then
            body_tree:add(F.f_admin_success, tvb:range(cur, 1)):append_text(tvb:range(cur, 1):uint() == 1 and " (OK)" or " (Failed)")
        end
        if body_available >= 9 then
            body_tree:add(F.f_topology_ver, tvb:range(cur + 1, 8))
        end
    elseif body_type == 0x0105 then
        -- DiscoverServiceRequest: tenant(u16+len) + service_name(u16+len)
        local end_off_d = cur + body_available
        local off_d = _M.read_string_field(body_tree, tvb, cur, end_off_d, F.f_tenant_len, F.f_tenant)
        _M.read_string_field(body_tree, tvb, off_d, end_off_d, F.f_svc_len, F.f_svc_name)
    elseif body_type == 0x0107 then
        -- ServiceSubscribeRequest: same as DiscoverServiceRequest (tenant + service_name)
        local end_off_s = cur + body_available
        local off_s = _M.read_string_field(body_tree, tvb, cur, end_off_s, F.f_tenant_len, F.f_tenant)
        _M.read_string_field(body_tree, tvb, off_s, end_off_s, F.f_svc_len, F.f_svc_name)
    elseif body_type == 0x0106 or body_type == 0x0108 then
        _M.parse_snapshot(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0109 then
        _M.parse_register_instance_with_meta(body_tree, tvb, cur, body_available)
    elseif body_type == 0x010A then
        _M.parse_register_meta_response(body_tree, tvb, cur, body_available)
    elseif body_type == 0x010B then
        _M.parse_filter_discovery_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x010C then
        _M.parse_filter_discovery_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0201 then
        -- GetConfigRequest: tenant + group + data_id (u16 len each)
        _M.parse_admin_delete_config_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0202 then
        _M.parse_config_response(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0203 then
        _M.parse_listen_config(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0204 then
        _M.parse_config_changed_notify(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0301 then
        _M.parse_raft_append_entries_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0302 then
        _M.parse_raft_append_entries_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0303 then
        _M.parse_raft_request_vote_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0304 then
        _M.parse_raft_request_vote_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0311 then
        _M.parse_distro_sync(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0312 then
        _M.parse_cluster_load_report(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0313 then
        _M.parse_leader_redirect(body_tree, tvb, cur, body_available)
    -- Admin plane: 0x0401-0x0422
    elseif body_type == 0x0401 then
        _M.parse_admin_list_services_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0402 then
        _M.parse_admin_list_services_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0403 then
        _M.parse_admin_put_config_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0404 or body_type == 0x0406 or body_type == 0x040C then
        _M.parse_admin_success_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0405 then
        _M.parse_admin_migration_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0408 then
        _M.parse_admin_list_tenants_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0409 then
        _M.parse_admin_list_configs_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x040A then
        _M.parse_admin_list_configs_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x040B then
        _M.parse_admin_delete_config_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x040D then
        _M.parse_admin_get_tenant_policy_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x040E then
        _M.parse_admin_get_tenant_policy_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0410 then
        _M.parse_admin_governance_state_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0411 or body_type == 0x0413 then
        _M.parse_admin_create_tenant_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0412 or body_type == 0x0414 or body_type == 0x0416 then
        _M.parse_admin_status_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0415 then
        _M.parse_admin_delete_tenant_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0417 then
        _M.parse_admin_get_stats_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0418 then
        _M.parse_admin_get_stats_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0419 then
        _M.parse_admin_create_credential_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x041A or body_type == 0x041C or body_type == 0x041E then
        _M.parse_admin_status_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x041B then
        _M.parse_admin_update_credential_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x041D then
        _M.parse_admin_delete_credential_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x041F then
        _M.parse_admin_list_credentials_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0420 then
        _M.parse_admin_list_credentials_res(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0421 then
        _M.parse_admin_query_listeners_req(body_tree, tvb, cur, body_available)
    elseif body_type == 0x0422 then
        _M.parse_admin_query_listeners_res(body_tree, tvb, cur, body_available)
    else
        -- Unknown opcode: show raw
        if body_available > 0 then
            body_tree:add(F.f_raw_bytes, tvb:range(cur, body_available)):set_text("Body (raw)")
        end
    end

    return frame_len
end

-- ============================================================
-- Top-level dissector with TCP reassembly (desegmentation)
-- ============================================================
function hmmp.dissector(tvb, pinfo, tree)
    local tvb_len = tvb:len()
    local bytes_consumed = 0

    while bytes_consumed < tvb_len do
        local result = dissect_one_frame(tvb, pinfo, tree, bytes_consumed)

        if result > 0 then
            -- Successfully dissected one frame
            bytes_consumed = bytes_consumed + result
        elseif result == 0 then
            -- Not our protocol or invalid magic at this offset
            return 0
        else
            -- Need more data (result is negative: bytes still needed)
            pinfo.desegment_offset = bytes_consumed
            pinfo.desegment_len = -result
            return tvb_len
        end
    end

    return bytes_consumed
end

-- ============================================================
-- TCP Port Registration & Heuristic Dissector
-- ============================================================

-- Register on configured port
local tcp_table = DissectorTable.get("tcp.port")
tcp_table:add(hmmp.prefs.port, hmmp)

-- Heuristic dissector: detect by magic number
function _M.hmmp_heuristic(tvb, pinfo, tree)
    if tvb:len() < 16 then return false end
    if tvb:range(0, 2):uint() ~= MAGIC then return false end
    -- Additional sanity: version should be reasonable
    local ver = tvb:range(2, 1):uint()
    if ver > 0x20 then return false end
    hmmp.dissector(tvb, pinfo, tree)
    return true
end

hmmp:register_heuristic("tcp", _M.hmmp_heuristic)

end -- end of do block (helper functions + dissector + registration)
