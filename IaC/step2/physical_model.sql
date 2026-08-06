--Criando os Schemas do Data Warehouse
DROP SCHEMA IF EXISTS staging CASCADE;
DROP SCHEMA IF EXISTS dw CASCADE;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS dw;
CREATE SCHEMA IF NOT EXISTS mart;

-- CRIANDO AS TABELAS DIMENSÃO DO DATA WAREHOUSE

--Criando a Tabela Dimensão de Cliente
CREATE TABLE IF NOT EXISTS staging.dim_customer (
    customer_id              VARCHAR(10) NOT NULL,
    customer_name            VARCHAR(50) NOT NULL,
    customer_type            VARCHAR(50),
    credit_terms_days        INTEGER,
    primary_freight_type     VARCHAR(50),
    account_status           VARCHAR(50),
    contract_start_date      DATE,
    annual_revenue_potential DECIMAL(15,2),

    PRIMARY KEY (customer_id)
)
DISTSTYLE ALL
SORTKEY (customer_id);

--Criando a Tabela Dimensão de Rota
CREATE TABLE IF NOT EXISTS staging.dim_route (
    route_id         VARCHAR(10) NOT NULL,
    origin_city      VARCHAR(50) NOT NULL,
    origin_state     VARCHAR(2)  NOT NULL,
    destination_city VARCHAR(50) NOT NULL,
    destination_state VARCHAR(2) NOT NULL,
    typical_distance_miles DECIMAL(10,2),
    base_rate_per_mile DECIMAL(10,2),
    fuel_surcharge_rate DECIMAL(8,2),
    typical_transit_days DECIMAL(6,2)
)
DISTSTYLE ALL
SORTKEY (route_id);

-- Criando a Tabela Dimensão de Motorista
CREATE TABLE IF NOT EXISTS staging.dim_driver (
    driver_id         VARCHAR(10) NOT NULL,
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    hire_date         DATE NOT NULL,
    termination_date  DATE,
    license_number   VARCHAR(20) NOT NULL,
    license_state     VARCHAR(2) NOT NULL,
    date_of_birth     DATE NOT NULL,
    home_terminal     VARCHAR(50) NOT NULL,
    employment_status VARCHAR(20) NOT NULL,
    cdl_class         VARCHAR(10) NOT NULL,
    years_experience  INTEGER NOT NULL

)
DISTSTYLE ALL
SORTKEY (driver_id);

-- Criando a Tabela Dimensão de Caminhões
CREATE TABLE IF NOT EXISTS staging.dim_truck (
    truck_id VARCHAR(10) NOT NULL,
    unit_number VARCHAR(20) NOT NULL,
    make VARCHAR(50) NOT NULL,
    model_year SMALLINT NOT NULL,
    vin VARCHAR(20) NOT NULL,
    acquisition_date DATE NOT NULL,
    acquisition_mileage DECIMAL(10,2) NOT NULL,
    fuel_type VARCHAR(20) NOT NULL,
    tank_capacity_gallons DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    home_terminal VARCHAR(50) NOT NULL

)
DISTSTYLE ALL
SORTKEY (truck_id);

-- Criando a Tabela Dimensão de Trailers
CREATE TABLE IF NOT EXISTS staging.dim_trailer (
    trailer_id VARCHAR(10) NOT NULL,
    trailer_number VARCHAR(20) NOT NULL,
    trailer_type VARCHAR(50) NOT NULL,
    length_feet DECIMAL(6,2) NOT NULL,
    model_year SMALLINT NOT NULL,
    vin VARCHAR(20) NOT NULL,
    acquisition_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    current_location VARCHAR(50) NOT NULL

)
DISTSTYLE ALL
SORTKEY (trailer_id);

-- Criando a Tabela Dimensão de Centros de Distribuição
CREATE TABLE IF NOT EXISTS staging.dim_facilities (
    facility_id VARCHAR(10) NOT NULL,
    facility_name VARCHAR(50) NOT NULL,
    facility_type VARCHAR(20) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(2) NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    dock_doors SMALLINT NOT NULL,
    operating_hours VARCHAR(50) NOT NULL
)
DISTSTYLE ALL
SORTKEY (facility_id);

--Criar a Tabela Dimensão de Localização
CREATE TABLE IF NOT EXISTS dw.dim_location (
    location_key BIGINT IDENTITY(1,1) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state VARCHAR(20) NOT NULL,
    country VARCHAR(20) NOT NULL,
    region VARCHAR(20) NOT NULL,
    location_description VARCHAR(100) NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,

    PRIMARY KEY (location_key)
)
DISTSTYLE ALL
SORTKEY (location_key);

CREATE TABLE IF NOT EXISTS dw.dim_date (
    date_key       INTEGER      NOT NULL,
    full_date      DATE         NOT NULL,
    day_number     SMALLINT     NOT NULL,
    day_name       VARCHAR(10)  NOT NULL,
    week_of_year   SMALLINT     NOT NULL,
    month_number   SMALLINT     NOT NULL,
    month_name     VARCHAR(10)  NOT NULL,
    quarter_number SMALLINT     NOT NULL,
    year_number    SMALLINT     NOT NULL,
    is_weekend     BOOLEAN      NOT NULL,

    PRIMARY KEY (date_key)
)
DISTSTYLE ALL
SORTKEY (full_date);

-- Criando a Tabela Dimensão de Perfil de Carga
CREATE TABLE IF NOT EXISTS dw.dim_load_profile (
    load_profile_key BIGINT IDENTITY(1,1) NOT NULL,
    load_type VARCHAR(20) NOT NULL,
    booking_type VARCHAR(20) NOT NULL,
    load_status VARCHAR(20) NOT NULL,

    PRIMARY KEY (load_profile_key)
)
DISTSTYLE ALL
SORTKEY (load_profile_key);

-- Criando a Tabela Dimensão de Status de Carga
CREATE TABLE IF NOT EXISTS dw.dim_trip_status (
    trip_status_key BIGINT IDENTITY(1,1) NOT NULL,
    trip_status VARCHAR(20) NOT NULL,
    status_group VARCHAR(20) NOT NULL,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    is_canceled BOOLEAN NOT NULL DEFAULT FALSE,

    PRIMARY KEY (trip_status_key)
)
DISTSTYLE ALL
SORTKEY (trip_status_key);

--Criando a Tabela Fato de Carga
CREATE TABLE IF NOT EXISTS staging.fact_load (
    load_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    route_id VARCHAR(20) NOT NULL,
    load_date DATE NOT NULL,
    load_type VARCHAR(20) NOT NULL,
    weight_lbs DECIMAL(15,2),
    pieces INTEGER,
    revenue DECIMAL(15,2),
    fuel_surcharge DECIMAL(15,2),
    accessorial_charges DECIMAL(15,2),
    load_status VARCHAR(20) NOT NULL,
    booking_type VARCHAR(20) NOT NULL
)
DISTSTYLE AUTO
SORTKEY (load_date);

--Criando a Tabela Fato de Entrega
CREATE TABLE IF NOT EXISTS staging.fact_trips (
    trip_id VARCHAR(20) NOT NULL,
    load_id VARCHAR(20) NOT NULL,
    driver_id VARCHAR(20) NOT NULL,
    truck_id VARCHAR(20) NOT NULL,
    trailer_id VARCHAR(20) NOT NULL,
    dispatch_date DATE NOT NULL,
    actual_distance_miles DECIMAL(10,2),
    actual_duration_hours DECIMAL(6,2),
    fuel_gallons_used DECIMAL(10,2),
    average_mpg DECIMAL(6,2),
    idle_time_hours DECIMAL(6,2),
    trip_status VARCHAR(10) NOT NULL DEFAULT 'To Be Defined'
)
DISTSTYLE AUTO
SORTKEY (dispatch_date);

--Criando a Tabela Fato de Eventos da Entrega
CREATE TABLE IF NOT EXISTS staging.fact_delivery_events (
    event_id VARCHAR(20) NOT NULL,
    load_id VARCHAR(20) NOT NULL,
    trip_id VARCHAR(20) NOT NULL,
    event_type VARCHAR(20) NOT NULL,
    facility_id VARCHAR(20) NOT NULL,
    scheduled_datetime TIMESTAMP NOT NULL,
    actual_datetime TIMESTAMP,
    detention_minutes DECIMAL(6,2),
    on_time_flag BOOLEAN NOT NULL DEFAULT FALSE,
    location_city VARCHAR(50) NOT NULL,
    location_state VARCHAR(2) NOT NULL
)
DISTSTYLE AUTO
SORTKEY (scheduled_datetime);

-- Criando a Tabela Fato de Combustível
CREATE TABLE IF NOT EXISTS staging.fact_fuel_purchases (
    fuel_purchase_id VARCHAR(20) NOT NULL,
    trip_id VARCHAR(20) NOT NULL,
    truck_id VARCHAR(20) NOT NULL,
    driver_id VARCHAR(20) NOT NULL,
    purchase_date TIMESTAMP NOT NULL,
    location_city VARCHAR(50) NOT NULL,
    location_state VARCHAR(2) NOT NULL,
    gallons DECIMAL(10,2) NOT NULL,
    price_per_gallon DECIMAL(10,2) NOT NULL,
    total_cost DECIMAL(15,2) NOT NULL,
    fuel_card_number VARCHAR(20) NOT NULL
)
DISTSTYLE AUTO
SORTKEY (purchase_date);

--Criando a Tabela Fato de Manutenção
CREATE TABLE IF NOT EXISTS staging.fact_maintenance (
    maintenance_id VARCHAR(20) NOT NULL,
    truck_id VARCHAR(20) NOT NULL,
    maintenance_date DATE NOT NULL,
    maintenance_type VARCHAR(50) NOT NULL,
    odometer_reading DECIMAL(10,2) NOT NULL,
    labor_hours DECIMAL(6,2) NOT NULL,
    labor_cost DECIMAL(15,2) NOT NULL,
    parts_cost DECIMAL(15,2) NOT NULL,
    total_cost DECIMAL(15,2) NOT NULL,
    facility_location VARCHAR(50) NOT NULL,
    downtime_hours DECIMAL(6,2) NOT NULL,
    service_description VARCHAR(255) NOT NULL
)
DISTSTYLE AUTO
SORTKEY (maintenance_date);

-- Criando a Tabela Fato de Ocorrências de Segurança
CREATE TABLE IF NOT EXISTS staging.fact_safety_incidents (
    incident_id VARCHAR(20) NOT NULL,
    trip_id VARCHAR(20) NOT NULL,
    truck_id VARCHAR(20) NOT NULL,
    driver_id VARCHAR(20) NOT NULL,
    incident_date TIMESTAMP NOT NULL,
    incident_type VARCHAR(50) NOT NULL,
    location_city VARCHAR(50) NOT NULL,
    location_state VARCHAR(2) NOT NULL,
    at_fault_flag BOOLEAN NOT NULL DEFAULT FALSE,
    injury_flag BOOLEAN NOT NULL DEFAULT FALSE,
    vehicle_damage_cost DECIMAL(15,2) NOT NULL,
    cargo_damage_cost DECIMAL(15,2) NOT NULL,
    claim_amount DECIMAL(15,2) NOT NULL,
    preventable_flag BOOLEAN NOT NULL DEFAULT FALSE,
    description VARCHAR(200) NOT NULL
)
DISTSTYLE AUTO
SORTKEY (incident_date);

-- Criando a Tabela Fato de Desempenho de Motoristas
CREATE TABLE IF NOT EXISTS staging.fact_driver_monthly_metrics (
    driver_id VARCHAR(20) NOT NULL,
    month DATE NOT NULL,
    trips_completed INT NOT NULL,
    total_miles DECIMAL(10,2) NOT NULL,
    total_revenue DECIMAL(15,2) NOT NULL,
    average_mpg DECIMAL(10,2) NOT NULL,
    total_fuel_gallons DECIMAL(10,2) NOT NULL,
    on_time_delivery_rate DECIMAL(5,2) NOT NULL,
    average_idle_hours DECIMAL(6,2) NOT NULL
)
DISTSTYLE AUTO
SORTKEY (month);

-- Criando a Tabela Fato de Uso de Veiculos
CREATE TABLE IF NOT EXISTS staging.fact_truck_utilization_metrics (
    truck_id VARCHAR(20) NOT NULL,
    month DATE NOT NULL,
    trips_completed INT NOT NULL,
    total_miles DECIMAL(10,2) NOT NULL,
    total_revenue DECIMAL(15,2) NOT NULL,
    average_mpg DECIMAL(10,2) NOT NULL,
    maintenance_events SMALLINT NOT NULL,
    maintenance_cost DECIMAL(15,2) NOT NULL,
    downtime_hours DECIMAL(6,2) NOT NULL,
    utilization_rate DECIMAL(5,2) NOT NULL
)
DISTSTYLE AUTO
SORTKEY (month);

-- Carga de arquivos CSV para as tabelas de staging
COPY staging.dim_customer
FROM 's3://prime-flow-bucket-792612172863/dados/customers.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.dim_route
FROM 's3://prime-flow-bucket-792612172863/dados/routes.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.dim_driver
FROM 's3://prime-flow-bucket-792612172863/dados/driver.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.dim_truck
FROM 's3://prime-flow-bucket-792612172863/dados/trucks.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.dim_trailer
FROM 's3://prime-flow-bucket-792612172863/dados/trailers.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.dim_facilities
FROM 's3://prime-flow-bucket-792612172863/dados/facilities.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.fact_load
FROM 's3://prime-flow-bucket-792612172863/dados/loads.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.fact_trips
FROM 's3://prime-flow-bucket-792612172863/dados/trips.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.fact_delivery_events
FROM 's3://prime-flow-bucket-792612172863/dados/delivery_events.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.fact_fuel_purchases
FROM 's3://prime-flow-bucket-792612172863/dados/fuel_purchases.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.fact_maintenance
FROM 's3://prime-flow-bucket-792612172863/dados/maintenance_records.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.fact_safety_incidents
FROM 's3://prime-flow-bucket-792612172863/dados/safety_incidents.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.fact_driver_monthly_metrics
FROM 's3://prime-flow-bucket-792612172863/dados/driver_monthly_metrics.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;

COPY staging.fact_truck_utilization_metrics
FROM 's3://prime-flow-bucket-792612172863/dados/truck_utilization_metrics.csv'
IAM_ROLE 'arn:aws:iam::792612172863:role/RedshiftS3AccessRole'
CSV
IGNOREHEADER 1;