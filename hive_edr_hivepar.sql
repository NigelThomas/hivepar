-- Table to be created in Hive for performance test

!set force on
CREATE SCHEMA hivepar;
!set force off


USE hivepar;

!set force on
DROP TABLE hive_edr_hivepar;
!set force off

-- we take 21 initial columns, then replicate each one twice (prefix by aa_ and bb_) to make 63; and add 7 partition columns


CREATE TABLE hive_edr_hivepar
(
    sn_end_time VARCHAR(32),
    sn_start_time VARCHAR(32),
    bearer_3gpp_imei VARCHAR(32),
    bearer_3gpp_imsi BIGINT,
    bearer_3gpp_rat_type INT,
    bearer_3gpp_user_location_information VARCHAR(32),
    ip_server_ip_address VARCHAR(16),
    ip_subscriber_ip_address VARCHAR(64),
    p2p_tls_sni VARCHAR(128),
    radius_calling_station_id BIGINT,
    sn_direction VARCHAR(16),
    sn_duration INT,
    sn_flow_end_time VARCHAR(32),
    sn_flow_id VARCHAR(32),
    sn_flow_start_time VARCHAR(32),
    sn_server_port INT,
    sn_subscriber_port INT,
    sn_volume_amt_ip_bytes_downlink INT,
    sn_volume_amt_ip_bytes_uplink INT,
    sn_closure_reason INT,
    event_label VARCHAR(16),
    aa_sn_end_time VARCHAR(32),
    aa_sn_start_time VARCHAR(32),
    aa_bearer_3gpp_imei VARCHAR(32),
    aa_bearer_3gpp_imsi BIGINT,
    aa_bearer_3gpp_rat_type INT,
    aa_bearer_3gpp_user_location_information VARCHAR(32),
    aa_ip_server_ip_address VARCHAR(16),
    aa_ip_subscriber_ip_address VARCHAR(64),
    aa_p2p_tls_sni VARCHAR(128),
    aa_radius_calling_station_id BIGINT,
    aa_sn_direction VARCHAR(16),
    aa_sn_duration INT,
    aa_sn_flow_end_time VARCHAR(32),
    aa_sn_flow_id VARCHAR(32),
    aa_sn_flow_start_time VARCHAR(32),
    aa_sn_server_port INT,
    aa_sn_subscriber_port INT,
    aa_sn_volume_amt_ip_bytes_downlink INT,
    aa_sn_volume_amt_ip_bytes_uplink INT,
    aa_sn_closure_reason INT,
    aa_event_label VARCHAR(16),
    bb_sn_end_time VARCHAR(32),
    bb_sn_start_time VARCHAR(32),
    bb_bearer_3gpp_imei VARCHAR(32),
    bb_bearer_3gpp_imsi BIGINT,
    bb_bearer_3gpp_rat_type INT,
    bb_bearer_3gpp_user_location_information VARCHAR(32),
    bb_ip_server_ip_address VARCHAR(16),
    bb_ip_subscriber_ip_address VARCHAR(64),
    bb_p2p_tls_sni VARCHAR(128),
    bb_radius_calling_station_id BIGINT,
    bb_sn_direction VARCHAR(16),
    bb_sn_duration INT,
    bb_sn_flow_end_time VARCHAR(32),
    bb_sn_flow_id VARCHAR(32),
    bb_sn_flow_start_time VARCHAR(32),
    bb_sn_server_port INT,
    bb_sn_subscriber_port INT,
    bb_sn_volume_amt_ip_bytes_downlink INT,
    bb_sn_volume_amt_ip_bytes_uplink INT,
    bb_sn_closure_reason INT,
    bb_event_label VARCHAR(16)
)
PARTITIONED BY (
    min INT,
    hour INT,
    day INT,
    month INT,
    year INT,
    app_id INT,
    cell_id INT
)
STORED AS ORC
LOCATION '/data/svc_sqlstream_guavus/hivepar_edr'
TBLPROPERTIES
( "orc.compress" = "SNAPPY"
);

