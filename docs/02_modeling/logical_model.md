# Modelo Lógico — Prime Flow Supply Chain

## 1. Objetivo
O objetivo deste documento é documentar o modelo lógico do Data Warehouse da Prime Flow Supply Chain.

Este documento descreve as tabelas dimensionais e tabelas fato, seus atributos, granularidades, relacionamentos, chaves e estratégias de tratamento histórico, servindo como referência para a construção do modelo físico no Amazon Redshift.

---

## 2. Convenções
| Sigla | Significado               |
| ----- | ------------------------- |
| PK    | Primary Key               |
| FK    | Foreign Key               |
| SK    | Surrogate Key             |
| NK    | Natural Key               |
| DD    | Degenerate Dimension      |
| SCD   | Slowly Changing Dimension |
| N/A   | Não aplicável             |

---

## 3. Dimensões

### 3.1 `dim_customer`

#### Objetivo
Armazenar as informações cadastrais e comerciais dos clientes da Prime Flow Supply Chain.

#### Origem

`customers.csv`

#### Granularidade
Uma linha representa uma versão histórica de um cliente.

#### Estratégia SCD
SCD Tipo 2.

Alterações em atributos como situação cadastral, tipo de cliente, condições de pagamento e tipo principal de frete devem gerar uma nova versão do registro.

#### Chaves
| Tipo | Campo          |
| ---- | -------------- |
| PK   | `customer_key` |
| NK   | `customer_id`  |

#### Campos
| Campo                      | Tipo lógico | Obrigatório | Descrição                              |
| -------------------------- | ----------- | :---------: | -------------------------------------- |
| `customer_key`             | SK          |     Sim     | Chave substituta da dimensão.          |
| `customer_id`              | NK          |     Sim     | Identificador do cliente na origem.    |
| `customer_name`            | Texto       |     Sim     | Nome do cliente.                       |
| `customer_type`            | Texto       |     Não     | Categoria comercial do cliente.        |
| `credit_terms_days`        | Inteiro     |     Não     | Prazo de pagamento em dias.            |
| `primary_freight_type`     | Texto       |     Não     | Tipo principal de frete contratado.    |
| `account_status`           | Texto       |     Não     | Situação cadastral do cliente.         |
| `contract_start_date`      | Data        |     Não     | Data de início do contrato.            |
| `annual_revenue_potential` | Decimal     |     Não     | Potencial anual de receita do cliente. |
| `effective_start_date`     | Data/Hora   |     Sim     | Início da validade da versão.          |
| `effective_end_date`       | Data/Hora   |     Não     | Fim da validade da versão.             |
| `is_current`               | Booleano    |     Sim     | Indica se a versão é a atual.          |

#### Relacionamentos
```text
dim_customer → fact_load
```

Cardinalidade:
```text
dim_customer 1:N fact_load
```

---

### 3.2 `dim_route`

#### Objetivo
Armazenar as características dos percursos planejados utilizados no transporte das cargas.

#### Origem
`routes.csv`

#### Granularidade
Uma linha representa uma rota cadastrada.

#### Estratégia SCD
SCD Tipo 1.

Correções em atributos da rota substituem os valores anteriores. Caso o negócio determine a necessidade de acompanhar alterações históricas de tarifas, distância ou prazo, a dimensão poderá evoluir para SCD Tipo 2.

#### Chaves
| Tipo | Campo       |
| ---- | ----------- |
| PK   | `route_key` |
| NK   | `route_id`  |

#### Campos
| Campo                    | Tipo lógico | Obrigatório | Descrição                           |
| ------------------------ | ----------- | :---------: | ----------------------------------- |
| `route_key`              | SK          |     Sim     | Chave substituta da dimensão.       |
| `route_id`               | NK          |     Sim     | Identificador da rota na origem.    |
| `origin_city`            | Texto       |     Sim     | Cidade de origem da rota.           |
| `origin_state`           | Texto       |     Sim     | Estado de origem.                   |
| `destination_city`       | Texto       |     Sim     | Cidade de destino.                  |
| `destination_state`      | Texto       |     Sim     | Estado de destino.                  |
| `typical_distance_miles` | Decimal     |     Não     | Distância típica da rota em milhas. |
| `base_rate_per_mile`     | Decimal     |     Não     | Tarifa-base por milha.              |
| `fuel_surcharge_rate`    | Decimal     |     Não     | Percentual ou taxa de combustível.  |
| `typical_transit_days`   | Decimal     |     Não     | Prazo típico de trânsito em dias.   |

#### Relacionamentos
```text
dim_route → fact_load
```

Cardinalidade:
```text
dim_route 1:N fact_load
```

---

### 3.3 `dim_driver`

#### Objetivo
Armazenar as informações cadastrais e profissionais dos motoristas.

#### Origem
`drivers.csv`

#### Granularidade
Uma linha representa uma versão histórica de um motorista.

#### Estratégia SCD
SCD Tipo 2.

Alterações em terminal de origem, situação empregatícia e classe da habilitação devem gerar nova versão.

#### Chaves
| Tipo | Campo        |
| ---- | ------------ |
| PK   | `driver_key` |
| NK   | `driver_id`  |

#### Campos
| Campo                  | Tipo lógico | Obrigatório | Descrição                             |
| ---------------------- | ----------- | :---------: | ------------------------------------- |
| `driver_key`           | SK          |     Sim     | Chave substituta da dimensão.         |
| `driver_id`            | NK          |     Sim     | Identificador do motorista na origem. |
| `first_name`           | Texto       |     Sim     | Primeiro nome.                        |
| `last_name`            | Texto       |     Sim     | Sobrenome.                            |
| `full_name`            | Texto       |     Sim     | Nome completo derivado.               |
| `hire_date`            | Data        |     Não     | Data de contratação.                  |
| `termination_date`     | Data        |     Não     | Data de desligamento.                 |
| `license_state`        | Texto       |     Não     | Estado de emissão da habilitação.     |
| `home_terminal`        | Texto       |     Não     | Terminal-base do motorista.           |
| `employment_status`    | Texto       |     Não     | Situação empregatícia.                |
| `cdl_class`            | Texto       |     Não     | Classe da habilitação profissional.   |
| `years_experience`     | Inteiro     |     Não     | Anos de experiência.                  |
| `effective_start_date` | Data/Hora   |     Sim     | Início da validade da versão.         |
| `effective_end_date`   | Data/Hora   |     Não     | Fim da validade da versão.            |
| `is_current`           | Booleano    |     Sim     | Indica se a versão é atual.           |

#### Relacionamentos
```text
dim_driver → fact_trip
dim_driver → fact_fuel_purchase
dim_driver → fact_safety_incident
```

---

### 3.4 `dim_truck`

#### Objetivo
Armazenar as características cadastrais e operacionais dos caminhões.

#### Origem
`trucks.csv`

#### Granularidade
Uma linha representa uma versão histórica de um caminhão.

#### Estratégia SCD
SCD Tipo 2.

Alterações no status operacional e no terminal de origem devem gerar nova versão.

#### Chaves
| Tipo | Campo       |
| ---- | ----------- |
| PK   | `truck_key` |
| NK   | `truck_id`  |

#### Campos
| Campo                   | Tipo lógico | Obrigatório | Descrição                              |
| ----------------------- | ----------- | :---------: | -------------------------------------- |
| `truck_key`             | SK          |     Sim     | Chave substituta da dimensão.          |
| `truck_id`              | NK          |     Sim     | Identificador do caminhão na origem.   |
| `unit_number`           | Texto       |     Sim     | Número operacional da unidade.         |
| `make`                  | Texto       |     Não     | Fabricante.                            |
| `model_year`            | Inteiro     |     Não     | Ano do modelo.                         |
| `acquisition_date`      | Data        |     Não     | Data de aquisição.                     |
| `acquisition_mileage`   | Decimal     |     Não     | Quilometragem no momento da aquisição. |
| `fuel_type`             | Texto       |     Não     | Tipo de combustível.                   |
| `tank_capacity_gallons` | Decimal     |     Não     | Capacidade do tanque em galões.        |
| `status`                | Texto       |     Não     | Situação operacional.                  |
| `home_terminal`         | Texto       |     Não     | Terminal-base do caminhão.             |
| `effective_start_date`  | Data/Hora   |     Sim     | Início da validade da versão.          |
| `effective_end_date`    | Data/Hora   |     Não     | Fim da validade da versão.             |
| `is_current`            | Booleano    |     Sim     | Indica se a versão é atual.            |

#### Relacionamentos
```text
dim_truck → fact_trip
dim_truck → fact_fuel_purchase
dim_truck → fact_maintenance
dim_truck → fact_safety_incident
```

---

### 3.5 `dim_trailer`

#### Objetivo
Armazenar as características cadastrais das carretas utilizadas nas viagens.

#### Origem
`trailers.csv`

#### Granularidade
Uma linha representa uma versão histórica de uma carreta.

#### Estratégia SCD
SCD Tipo 2.

Alterações no status e na localização atual podem gerar nova versão.

#### Chaves
| Tipo | Campo         |
| ---- | ------------- |
| PK   | `trailer_key` |
| NK   | `trailer_id`  |

#### Campos
| Campo                  | Tipo lógico | Obrigatório | Descrição                           |
| ---------------------- | ----------- | :---------: | ----------------------------------- |
| `trailer_key`          | SK          |     Sim     | Chave substituta da dimensão.       |
| `trailer_id`           | NK          |     Sim     | Identificador da carreta na origem. |
| `trailer_number`       | Texto       |     Sim     | Número operacional da carreta.      |
| `trailer_type`         | Texto       |     Não     | Tipo da carreta.                    |
| `length_feet`          | Decimal     |     Não     | Comprimento em pés.                 |
| `model_year`           | Inteiro     |     Não     | Ano do modelo.                      |
| `acquisition_date`     | Data        |     Não     | Data de aquisição.                  |
| `status`               | Texto       |     Não     | Situação operacional.               |
| `current_location`     | Texto       |     Não     | Localização atual.                  |
| `effective_start_date` | Data/Hora   |     Sim     | Início da validade da versão.       |
| `effective_end_date`   | Data/Hora   |     Não     | Fim da validade da versão.          |
| `is_current`           | Booleano    |     Sim     | Indica se a versão é atual.         |

#### Relacionamentos
```text
dim_trailer → fact_trip
```

---

### 3.6 `dim_facility`

#### Objetivo
Armazenar as informações das instalações onde ocorrem coletas e entregas.

#### Origem
`facilities.csv`

#### Granularidade
Uma linha representa uma instalação.

#### Estratégia SCD
SCD Tipo 1.

#### Chaves
| Tipo | Campo          |
| ---- | -------------- |
| PK   | `facility_key` |
| NK   | `facility_id`  |

#### Campos
| Campo             | Tipo lógico | Obrigatório | Descrição                    |
| ----------------- | ----------- | :---------: | ---------------------------- |
| `facility_key`    | SK          |     Sim     | Chave substituta.            |
| `facility_id`     | NK          |     Sim     | Identificador da instalação. |
| `facility_name`   | Texto       |     Sim     | Nome da instalação.          |
| `facility_type`   | Texto       |     Não     | Tipo da instalação.          |
| `city`            | Texto       |     Não     | Cidade.                      |
| `state`           | Texto       |     Não     | Estado.                      |
| `latitude`        | Decimal     |     Não     | Latitude.                    |
| `longitude`       | Decimal     |     Não     | Longitude.                   |
| `dock_doors`      | Inteiro     |     Não     | Quantidade de docas.         |
| `operating_hours` | Texto       |     Não     | Horário de funcionamento.    |

#### Relacionamentos
```text
dim_facility → fact_delivery_event
```

---

### 3.7 `dim_location`

#### Objetivo
Padronizar localizações utilizadas em eventos, abastecimentos, manutenções e incidentes.

#### Origem
Derivada dos campos de cidade, estado e localização presentes nos arquivos transacionais.

#### Granularidade
Uma linha representa uma combinação única de localização.

#### Estratégia SCD
SCD Tipo 1.

#### Chaves
| Tipo | Campo                         |
| ---- | ----------------------------- |
| PK   | `location_key`                |
| NK   | Combinação de cidade e estado |

#### Campos
| Campo                  | Tipo lógico | Obrigatório | Descrição                             |
| ---------------------- | ----------- | :---------: | ------------------------------------- |
| `location_key`         | SK          |     Sim     | Chave substituta.                     |
| `city`                 | Texto       |     Não     | Cidade.                               |
| `state`                | Texto       |     Não     | Estado.                               |
| `country`              | Texto       |     Não     | País.                                 |
| `region`               | Texto       |     Não     | Região analítica.                     |
| `location_description` | Texto       |     Não     | Descrição consolidada da localização. |

#### Relacionamentos
```text
dim_location → fact_delivery_event
dim_location → fact_fuel_purchase
dim_location → fact_maintenance
dim_location → fact_safety_incident
```

---

### 3.8 `dim_date`

#### Objetivo
Disponibilizar atributos de calendário para análises temporais.

#### Origem
Gerada internamente pelo processo ETL/ELT.

#### Granularidade
Uma linha representa uma data.

#### Estratégia SC
Não aplicável.

#### Chaves
| Tipo | Campo       |
| ---- | ----------- |
| PK   | `date_key`  |
| NK   | `full_date` |

#### Campos
| Campo          | Tipo lógico | Obrigatório | Descrição                |
| -------------- | ----------- | :---------: | ------------------------ |
| `date_key`     | SK          |     Sim     | Chave numérica da data.  |
| `full_date`    | Data        |     Sim     | Data completa.           |
| `day`          | Inteiro     |     Sim     | Dia do mês.              |
| `day_name`     | Texto       |     Sim     | Nome do dia da semana.   |
| `day_of_week`  | Inteiro     |     Sim     | Número do dia da semana. |
| `week_of_year` | Inteiro     |     Sim     | Semana do ano.           |
| `month`        | Inteiro     |     Sim     | Número do mês.           |
| `month_name`   | Texto       |     Sim     | Nome do mês.             |
| `quarter`      | Inteiro     |     Sim     | Trimestre.               |
| `year`         | Inteiro     |     Sim     | Ano.                     |
| `is_weekend`   | Booleano    |     Sim     | Indica final de semana.  |

#### Dimensão desempenhando papéis
A dimensão será reutilizada com diferentes papéis:

* `load_date_key`;
* `dispatch_date_key`;
* `scheduled_date_key`;
* `actual_date_key`;
* `purchase_date_key`;
* `maintenance_date_key`;
* `incident_date_key`.

---

### 3.9 `dim_load_profile`

#### Objetivo
Agrupar atributos classificatórios de baixa cardinalidade relacionados à carga.

#### Origem
`loads.csv`

#### Granularidade
Uma linha representa uma combinação única de tipo, modalidade e status de carga.

#### Estratégia SCD
SCD Tipo 1.

#### Chaves
| Tipo | Campo                                     |
| ---- | ----------------------------------------- |
| PK   | `load_profile_key`                        |
| NK   | Combinação dos atributos classificatórios |

#### Campos
| Campo              | Tipo lógico | Obrigatório | Descrição                                 |
| ------------------ | ----------- | :---------: | ----------------------------------------- |
| `load_profile_key` | SK          |     Sim     | Chave substituta.                         |
| `load_type`        | Texto       |     Não     | Tipo da carga.                            |
| `booking_type`     | Texto       |     Não     | Modalidade de contratação ou agendamento. |
| `load_status`      | Texto       |     Não     | Status operacional da carga.              |

#### Relacionamentos
```text
dim_load_profile → fact_load
```

---

### 3.10 `dim_trip_status`

#### Objetivo
Padronizar os status das viagens.

#### Origem
`trips.csv`

#### Granularidade
Uma linha representa um status de viagem.

#### Estratégia SCD
SCD Tipo 1.

#### Chaves
| Tipo | Campo             |
| ---- | ----------------- |
| PK   | `trip_status_key` |
| NK   | `trip_status`     |

#### Campos
| Campo             | Tipo lógico | Obrigatório | Descrição                          |
| ----------------- | ----------- | :---------: | ---------------------------------- |
| `trip_status_key` | SK          |     Sim     | Chave substituta.                  |
| `trip_status`     | Texto       |     Sim     | Status da viagem.                  |
| `status_group`    | Texto       |     Não     | Agrupamento analítico do status.   |
| `is_completed`    | Booleano    |     Não     | Indica se representa conclusão.    |
| `is_cancelled`    | Booleano    |     Não     | Indica se representa cancelamento. |

#### Relacionamentos
```text
dim_trip_status → fact_trip
```

---

## 4. Tabelas fato

### 4.1 `fact_load`

#### Objetivo
Registrar os dados comerciais e operacionais de cada carga contratada.

#### Origem
`loads.csv`

#### Granularidade
Uma linha representa uma carga.

#### Chaves
| Tipo | Campo      |
| ---- | ---------- |
| PK   | `load_key` |
| DD   | `load_id`  |

#### Chaves estrangeiras
| Campo              | Referência         | Obrigatório |
| ------------------ | ------------------ | :---------: |
| `customer_key`     | `dim_customer`     |     Sim     |
| `route_key`        | `dim_route`        |     Sim     |
| `load_date_key`    | `dim_date`         |     Sim     |
| `load_profile_key` | `dim_load_profile` |     Não     |

#### Campos e medidas
| Campo                 | Tipo lógico | Classificação   | Descrição                         |
| --------------------- | ----------- | --------------- | --------------------------------- |
| `load_key`            | SK          | PK              | Identificador interno da fato.    |
| `load_id`             | Texto       | DD              | Identificador da carga na origem. |
| `customer_key`        | SK          | FK              | Cliente relacionado.              |
| `route_key`           | SK          | FK              | Rota relacionada.                 |
| `load_date_key`       | SK          | FK              | Data da carga.                    |
| `load_profile_key`    | SK          | FK              | Perfil classificatório da carga.  |
| `weight_lbs`          | Decimal     | Medida aditiva  | Peso da carga.                    |
| `pieces`              | Inteiro     | Medida aditiva  | Quantidade de volumes.            |
| `revenue`             | Decimal     | Medida aditiva  | Receita-base.                     |
| `fuel_surcharge`      | Decimal     | Medida aditiva  | Sobretaxa de combustível.         |
| `accessorial_charges` | Decimal     | Medida aditiva  | Encargos adicionais.              |
| `total_load_revenue`  | Decimal     | Medida derivada | Receita total da carga.           |
| `load_count`          | Inteiro     | Indicador       | Valor constante igual a 1.        |

#### Regra derivada
```text
total_load_revenue =
revenue + fuel_surcharge + accessorial_charges
```

---

### 4.2 `fact_trip`

#### Objetivo
Registrar a execução operacional das viagens.

#### Origem
`trips.csv`

#### Granularidade
Uma linha representa uma viagem.

#### Chaves
| Tipo | Campo      |
| ---- | ---------- |
| PK   | `trip_key` |
| DD   | `trip_id`  |
| DD   | `load_id`  |

#### Chaves estrangeiras
| Campo               | Referência        | Obrigatório |
| ------------------- | ----------------- | :---------: |
| `driver_key`        | `dim_driver`      |     Não     |
| `truck_key`         | `dim_truck`       |     Não     |
| `trailer_key`       | `dim_trailer`     |     Não     |
| `dispatch_date_key` | `dim_date`        |     Sim     |
| `trip_status_key`   | `dim_trip_status` |     Não     |

#### Campos e medidas
| Campo                   | Tipo lógico | Classificação      | Descrição                            |
| ----------------------- | ----------- | ------------------ | ------------------------------------ |
| `trip_key`              | SK          | PK                 | Identificador interno.               |
| `trip_id`               | Texto       | DD                 | Identificador da viagem na origem.   |
| `load_id`               | Texto       | DD                 | Identificador da carga transportada. |
| `driver_key`            | SK          | FK                 | Motorista responsável.               |
| `truck_key`             | SK          | FK                 | Caminhão utilizado.                  |
| `trailer_key`           | SK          | FK                 | Carreta utilizada.                   |
| `dispatch_date_key`     | SK          | FK                 | Data do despacho.                    |
| `trip_status_key`       | SK          | FK                 | Status da viagem.                    |
| `actual_distance_miles` | Decimal     | Medida aditiva     | Distância efetivamente percorrida.   |
| `actual_duration_hours` | Decimal     | Medida aditiva     | Duração da viagem.                   |
| `fuel_gallons_used`     | Decimal     | Medida aditiva     | Combustível utilizado.               |
| `average_mpg`           | Decimal     | Medida não aditiva | Consumo médio informado na origem.   |
| `idle_time_hours`       | Decimal     | Medida aditiva     | Tempo ocioso.                        |
| `trip_count`            | Inteiro     | Indicador          | Valor constante igual a 1.           |

#### Regra de agregação
O indicador `average_mpg` não deve ser somado ou calculado por média simples.

```text
MPG consolidado =
Soma das milhas percorridas
÷
Soma dos galões utilizados
```

---

### 4.3 `fact_delivery_event`

#### Objetivo
Registrar os eventos de coleta e entrega executados durante as viagens.

#### Origem
`delivery_events.csv`

#### Granularidade
Uma linha representa um evento logístico.

#### Chaves
| Tipo | Campo                |
| ---- | -------------------- |
| PK   | `delivery_event_key` |
| DD   | `event_id`           |
| DD   | `load_id`            |
| DD   | `trip_id`            |

#### Chaves estrangeiras
| Campo                | Referência     | Obrigatório |
| -------------------- | -------------- | :---------: |
| `facility_key`       | `dim_facility` |     Não     |
| `location_key`       | `dim_location` |     Não     |
| `scheduled_date_key` | `dim_date`     |     Não     |
| `actual_date_key`    | `dim_date`     |     Não     |

#### Campos e medidas
| Campo                       | Tipo lógico | Classificação      | Descrição                             |
| --------------------------- | ----------- | ------------------ | ------------------------------------- |
| `delivery_event_key`        | SK          | PK                 | Identificador interno.                |
| `event_id`                  | Texto       | DD                 | Identificador do evento.              |
| `load_id`                   | Texto       | DD                 | Carga relacionada.                    |
| `trip_id`                   | Texto       | DD                 | Viagem relacionada.                   |
| `event_type`                | Texto       | Atributo           | Tipo do evento: Pickup ou Delivery.   |
| `facility_key`              | SK          | FK                 | Instalação relacionada.               |
| `location_key`              | SK          | FK                 | Localização do evento.                |
| `scheduled_date_key`        | SK          | FK                 | Data prevista.                        |
| `actual_date_key`           | SK          | FK                 | Data realizada.                       |
| `scheduled_datetime`        | Data/Hora   | Atributo temporal  | Data e hora previstas.                |
| `actual_datetime`           | Data/Hora   | Atributo temporal  | Data e hora realizadas.               |
| `detention_minutes`         | Decimal     | Medida aditiva     | Minutos de retenção.                  |
| `on_time_flag`              | Booleano    | Indicador          | Indica pontualidade.                  |
| `schedule_variance_minutes` | Decimal     | Medida derivada    | Diferença entre realizado e previsto. |
| `event_count`               | Inteiro     | Indicador          | Valor constante igual a 1.            |
| `on_time_event_count`       | Inteiro     | Indicador derivado | Valor 1 para evento pontual.          |
| `late_event_count`          | Inteiro     | Indicador derivado | Valor 1 para evento atrasado.         |

---

### 4.4 `fact_fuel_purchase`

#### Objetivo
Registrar as transações de compra de combustível.

#### Origem
`fuel_purchases.csv`

#### Granularidade
Uma linha representa uma compra de combustível.

#### Chaves
| Tipo | Campo               |
| ---- | ------------------- |
| PK   | `fuel_purchase_key` |
| DD   | `fuel_purchase_id`  |
| DD   | `trip_id`           |

#### Chaves estrangeiras
| Campo               | Referência     | Obrigatório |
| ------------------- | -------------- | :---------: |
| `driver_key`        | `dim_driver`   |     Não     |
| `truck_key`         | `dim_truck`    |     Sim     |
| `purchase_date_key` | `dim_date`     |     Sim     |
| `location_key`      | `dim_location` |     Não     |

#### Campos e medidas
| Campo                 | Tipo lógico | Classificação      | Descrição                  |
| --------------------- | ----------- | ------------------ | -------------------------- |
| `fuel_purchase_key`   | SK          | PK                 | Identificador interno.     |
| `fuel_purchase_id`    | Texto       | DD                 | Identificador da compra.   |
| `trip_id`             | Texto       | DD                 | Viagem relacionada.        |
| `driver_key`          | SK          | FK                 | Motorista relacionado.     |
| `truck_key`           | SK          | FK                 | Caminhão abastecido.       |
| `purchase_date_key`   | SK          | FK                 | Data da compra.            |
| `location_key`        | SK          | FK                 | Local do abastecimento.    |
| `gallons`             | Decimal     | Medida aditiva     | Quantidade abastecida.     |
| `price_per_gallon`    | Decimal     | Medida não aditiva | Preço unitário.            |
| `total_cost`          | Decimal     | Medida aditiva     | Custo total.               |
| `fuel_purchase_count` | Inteiro     | Indicador          | Valor constante igual a 1. |

#### Observação de segurança
O campo `fuel_card_number` não deve ser disponibilizado integralmente na camada de consumo. Caso seja necessário para auditoria, deve ser mascarado.

---

### 4.5 `fact_maintenance`

#### Objetivo
Registrar os eventos de manutenção executados nos caminhões.

#### Origem
`maintenance_records.csv`

#### Granularidade
Uma linha representa um registro de manutenção.

#### Chaves
| Tipo | Campo             |
| ---- | ----------------- |
| PK   | `maintenance_key` |
| DD   | `maintenance_id`  |

#### Chaves estrangeiras
| Campo                  | Referência     | Obrigatório |
| ---------------------- | -------------- | :---------: |
| `truck_key`            | `dim_truck`    |     Sim     |
| `maintenance_date_key` | `dim_date`     |     Sim     |
| `location_key`         | `dim_location` |     Não     |

#### Campos e medidas
| Campo                  | Tipo lógico | Classificação      | Descrição                    |
| ---------------------- | ----------- | ------------------ | ---------------------------- |
| `maintenance_key`      | SK          | PK                 | Identificador interno.       |
| `maintenance_id`       | Texto       | DD                 | Identificador da manutenção. |
| `truck_key`            | SK          | FK                 | Caminhão atendido.           |
| `maintenance_date_key` | SK          | FK                 | Data da manutenção.          |
| `location_key`         | SK          | FK                 | Local da manutenção.         |
| `maintenance_type`     | Texto       | Atributo           | Tipo da manutenção.          |
| `service_description`  | Texto       | Atributo           | Descrição do serviço.        |
| `odometer_reading`     | Decimal     | Medida não aditiva | Leitura do odômetro.         |
| `labor_hours`          | Decimal     | Medida aditiva     | Horas de mão de obra.        |
| `labor_cost`           | Decimal     | Medida aditiva     | Custo de mão de obra.        |
| `parts_cost`           | Decimal     | Medida aditiva     | Custo de peças.              |
| `total_cost`           | Decimal     | Medida aditiva     | Custo total da manutenção.   |
| `downtime_hours`       | Decimal     | Medida aditiva     | Horas de indisponibilidade.  |
| `maintenance_count`    | Inteiro     | Indicador          | Valor constante igual a 1.   |

---

### 4.6 `fact_safety_incident`

#### Objetivo
Registrar os incidentes de segurança relacionados às operações de transporte.

#### Origem
`safety_incidents.csv`

#### Granularidade
Uma linha representa um incidente de segurança.

#### Chaves
| Tipo | Campo                 |
| ---- | --------------------- |
| PK   | `safety_incident_key` |
| DD   | `incident_id`         |
| DD   | `trip_id`             |

#### Chaves estrangeiras
| Campo               | Referência     | Obrigatório |
| ------------------- | -------------- | :---------: |
| `driver_key`        | `dim_driver`   |     Não     |
| `truck_key`         | `dim_truck`    |     Não     |
| `incident_date_key` | `dim_date`     |     Sim     |
| `location_key`      | `dim_location` |     Não     |

#### Campos e medidas
| Campo                        | Tipo lógico | Classificação      | Descrição                                |
| ---------------------------- | ----------- | ------------------ | ---------------------------------------- |
| `safety_incident_key`        | SK          | PK                 | Identificador interno.                   |
| `incident_id`                | Texto       | DD                 | Identificador do incidente.              |
| `trip_id`                    | Texto       | DD                 | Viagem relacionada.                      |
| `driver_key`                 | SK          | FK                 | Motorista envolvido.                     |
| `truck_key`                  | SK          | FK                 | Caminhão envolvido.                      |
| `incident_date_key`          | SK          | FK                 | Data do incidente.                       |
| `location_key`               | SK          | FK                 | Local do incidente.                      |
| `incident_type`              | Texto       | Atributo           | Tipo do incidente.                       |
| `at_fault_flag`              | Booleano    | Indicador          | Indica responsabilidade.                 |
| `injury_flag`                | Booleano    | Indicador          | Indica ocorrência de feridos.            |
| `preventable_flag`           | Booleano    | Indicador          | Indica se poderia ter sido evitado.      |
| `description`                | Texto       | Atributo           | Descrição da ocorrência.                 |
| `vehicle_damage_cost`        | Decimal     | Medida aditiva     | Custo dos danos ao veículo.              |
| `cargo_damage_cost`          | Decimal     | Medida aditiva     | Custo dos danos à carga.                 |
| `claim_amount`               | Decimal     | Medida aditiva     | Valor da reclamação ou indenização.      |
| `incident_count`             | Inteiro     | Indicador          | Valor constante igual a 1.               |
| `injury_incident_count`      | Inteiro     | Indicador derivado | Valor 1 quando houver feridos.           |
| `preventable_incident_count` | Inteiro     | Indicador derivado | Valor 1 quando o incidente for evitável. |
| `at_fault_incident_count`    | Inteiro     | Indicador derivado | Valor 1 quando houver responsabilidade.  |

---

## 5. Relacionamentos
| Dimensão de origem | Tabela fato de destino | Cardinalidade |
| ------------------ | ---------------------- | ------------- |
| `dim_customer`     | `fact_load`            | 1:N           |
| `dim_route`        | `fact_load`            | 1:N           |
| `dim_load_profile` | `fact_load`            | 1:N           |
| `dim_date`         | `fact_load`            | 1:N           |
| `dim_driver`       | `fact_trip`            | 1:N           |
| `dim_truck`        | `fact_trip`            | 1:N           |
| `dim_trailer`      | `fact_trip`            | 1:N           |
| `dim_trip_status`  | `fact_trip`            | 1:N           |
| `dim_date`         | `fact_trip`            | 1:N           |
| `dim_facility`     | `fact_delivery_event`  | 1:N           |
| `dim_location`     | `fact_delivery_event`  | 1:N           |
| `dim_date`         | `fact_delivery_event`  | 1:N           |
| `dim_driver`       | `fact_fuel_purchase`   | 1:N           |
| `dim_truck`        | `fact_fuel_purchase`   | 1:N           |
| `dim_location`     | `fact_fuel_purchase`   | 1:N           |
| `dim_date`         | `fact_fuel_purchase`   | 1:N           |
| `dim_truck`        | `fact_maintenance`     | 1:N           |
| `dim_location`     | `fact_maintenance`     | 1:N           |
| `dim_date`         | `fact_maintenance`     | 1:N           |
| `dim_driver`       | `fact_safety_incident` | 1:N           |
| `dim_truck`        | `fact_safety_incident` | 1:N           |
| `dim_location`     | `fact_safety_incident` | 1:N           |
| `dim_date`         | `fact_safety_incident` | 1:N           |

---

## 6. Estratégia SCD
| Dimensão           | Estratégia | Atributos principais                                     |
| ------------------ | ---------- | -------------------------------------------------------- |
| `dim_customer`     | SCD Tipo 2 | Tipo, status, prazo de pagamento e tipo de frete.        |
| `dim_route`        | SCD Tipo 1 | Correções cadastrais e operacionais.                     |
| `dim_driver`       | SCD Tipo 2 | Terminal, situação empregatícia e classe de habilitação. |
| `dim_truck`        | SCD Tipo 2 | Status e terminal.                                       |
| `dim_trailer`      | SCD Tipo 2 | Status e localização atual.                              |
| `dim_facility`     | SCD Tipo 1 | Dados cadastrais da instalação.                          |
| `dim_location`     | SCD Tipo 1 | Padronização geográfica.                                 |
| `dim_date`         | N/A        | Dimensão estática de calendário.                         |
| `dim_load_profile` | SCD Tipo 1 | Classificações de carga.                                 |
| `dim_trip_status`  | SCD Tipo 1 | Classificações de status.                                |

---

## 7. Dimensões degeneradas
| Tabela fato            | Campo degenerado   | Finalidade                      |
| ---------------------- | ------------------ | ------------------------------- |
| `fact_load`            | `load_id`          | Identificar e rastrear a carga. |
| `fact_trip`            | `trip_id`          | Identificar a viagem.           |
| `fact_trip`            | `load_id`          | Rastrear a carga associada.     |
| `fact_delivery_event`  | `event_id`         | Identificar o evento.           |
| `fact_delivery_event`  | `load_id`          | Rastrear a carga.               |
| `fact_delivery_event`  | `trip_id`          | Rastrear a viagem.              |
| `fact_fuel_purchase`   | `fuel_purchase_id` | Identificar a compra.           |
| `fact_fuel_purchase`   | `trip_id`          | Rastrear a viagem.              |
| `fact_maintenance`     | `maintenance_id`   | Identificar a manutenção.       |
| `fact_safety_incident` | `incident_id`      | Identificar o incidente.        |
| `fact_safety_incident` | `trip_id`          | Rastrear a viagem.              |

---

## 8. Regras gerais de implementação lógica

* Todas as dimensões possuirão chaves substitutas.

* As chaves naturais serão preservadas para rastreabilidade e integração com a origem.

* Registros dimensionais não identificados utilizarão uma chave padrão para membros desconhecidos.

* As tabelas fato possuirão indicadores de contagem com valor igual a 1.

* As tabelas fato não serão relacionadas diretamente entre si por chaves estrangeiras.

* Os identificadores operacionais permanecerão nas tabelas fato como dimensões degeneradas.

* A dimensão Data será compartilhada entre todos os processos de negócio.

* Campos de média e proporção não serão tratados como medidas aditivas.

* Informações pessoais ou sensíveis terão sua exposição controlada.

* As estratégias de distribuição, ordenação, compressão, tipos físicos e tamanhos dos campos serão definidas no modelo físico.

---