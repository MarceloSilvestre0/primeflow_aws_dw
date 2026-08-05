# Modelo Dimensional — Prime Flow Supply Chain

## 1. Objetivo
Este documento apresenta a proposta de modelagem dimensional para o Data Warehouse da Prime Flow Supply Chain.

O modelo foi elaborado com base nos processos de contratação de cargas, execução de viagens, eventos logísticos, abastecimentos, manutenção da frota e segurança operacional.

A modelagem segue os princípios da metodologia Kimball, separando os processos de negócio em tabelas fato com granularidades próprias e utilizando dimensões conformadas para permitir análises integradas.

---

## 2. Processos de negócio identificados
| Processo             | Arquivo principal         | Granularidade proposto                             |
| -------------------- | ------------------------- | ----------------------------------------- |
| Contratação de carga | `loads.csv`               | Uma linha por carga                       |
| Execução de viagem   | `trips.csv`               | Uma linha por viagem                      |
| Evento logístico     | `delivery_events.csv`     | Uma linha por evento de coleta ou entrega |
| Abastecimento        | `fuel_purchases.csv`      | Uma linha por compra de combustível       |
| Manutenção           | `maintenance_records.csv` | Uma linha por evento de manutenção        |
| Segurança            | `safety_incidents.csv`    | Uma linha por incidente de segurança      |

---

## 3. Dimensões conformadas

### 3.1 `dim_date`

Dimensão de calendário compartilhada entre todos os processos fato.

A mesma dimensão será utilizada com diferentes papéis, como:

* data da carga;
* data do despacho;
* data prevista do evento;
* data real do evento;
* data do abastecimento;
* data da manutenção;
* data do incidente.

Atributos sugeridos:

| Atributo       | Descrição                            |
| -------------- | ------------------------------------ |
| `date_key`     | Chave substituta no formato numérico |
| `full_date`    | Data completa                        |
| `day`          | Dia do mês                           |
| `day_name`     | Nome do dia da semana                |
| `week_of_year` | Semana do ano                        |
| `month`        | Número do mês                        |
| `month_name`   | Nome do mês                          |
| `quarter`      | Trimestre                            |
| `year`         | Ano                                  |
| `is_weekend`   | Indicador de final de semana         |

---

### 3.2 `dim_customer`

Origem: `customers.csv`

Descreve os clientes que contratam os serviços da Prime Flow.

Atributos sugeridos:

| Atributo                   | Descrição                        |
| -------------------------- | -------------------------------- |
| `customer_key`             | Chave substituta                 |
| `customer_id`              | Chave natural da origem          |
| `customer_name`            | Nome do cliente                  |
| `customer_type`            | Tipo de relacionamento comercial |
| `credit_terms_days`        | Prazo de pagamento               |
| `primary_freight_type`     | Tipo principal de frete          |
| `account_status`           | Situação da conta                |
| `contract_start_date`      | Data de início do contrato       |
| `annual_revenue_potential` | Potencial anual de receita       |

Possível estratégia histórica: SCD Tipo 2 para `customer_type`, `account_status`, `credit_terms_days` e `primary_freight_type`.

---

### 3.3 `dim_route`

Origem: `routes.csv`

Descreve os percursos planejados utilizados no transporte.

Atributos sugeridos:

| Atributo                 | Descrição                |
| ------------------------ | ------------------------ |
| `route_key`              | Chave substituta         |
| `route_id`               | Chave natural            |
| `origin_city`            | Cidade de origem         |
| `origin_state`           | Estado de origem         |
| `destination_city`       | Cidade de destino        |
| `destination_state`      | Estado de destino        |
| `typical_distance_miles` | Distância típica         |
| `base_rate_per_mile`     | Tarifa-base por milha    |
| `fuel_surcharge_rate`    | Taxa de combustível      |
| `typical_transit_days`   | Tempo típico de trânsito |

---

### 3.4 `dim_driver`

Origem: `drivers.csv`

Descreve os motoristas da operação.

Atributos sugeridos:

| Atributo            | Descrição             |
| ------------------- | --------------------- |
| `driver_key`        | Chave substituta      |
| `driver_id`         | Chave natural         |
| `driver_name`       | Nome completo         |
| `hire_date`         | Data de contratação   |
| `termination_date`  | Data de desligamento  |
| `license_state`     | Estado da habilitação |
| `home_terminal`     | Terminal de origem    |
| `employment_status` | Situação empregatícia |
| `cdl_class`         | Classe da habilitação |
| `years_experience`  | Anos de experiência   |

---

### 3.5 `dim_truck`

Origem: `trucks.csv`

Descreve os caminhões utilizados nas viagens.

Atributos sugeridos:

| Atributo                | Descrição                  |
| ----------------------- | -------------------------- |
| `truck_key`             | Chave substituta           |
| `truck_id`              | Chave natural              |
| `unit_number`           | Número operacional         |
| `make`                  | Fabricante                 |
| `model_year`            | Ano do modelo              |
| `acquisition_date`      | Data de aquisição          |
| `acquisition_mileage`   | Quilometragem de aquisição |
| `fuel_type`             | Tipo de combustível        |
| `tank_capacity_gallons` | Capacidade do tanque       |
| `status`                | Situação operacional       |
| `home_terminal`         | Terminal de origem         |

---

### 3.6 `dim_trailer`

Origem: `trailers.csv`

Descreve as carretas ou implementos utilizados no transporte.

Atributos sugeridos:

| Atributo           | Descrição            |
| ------------------ | -------------------- |
| `trailer_key`      | Chave substituta     |
| `trailer_id`       | Chave natural        |
| `trailer_number`   | Número operacional   |
| `trailer_type`     | Tipo da carreta      |
| `length_feet`      | Comprimento          |
| `model_year`       | Ano do modelo        |
| `acquisition_date` | Data de aquisição    |
| `status`           | Situação operacional |
| `current_location` | Localização atual    |

---

### 3.7 `dim_facility`

Origem: `facilities.csv`

Descreve as instalações onde ocorrem eventos de coleta e entrega.

Atributos sugeridos:

| Atributo          | Descrição                |
| ----------------- | ------------------------ |
| `facility_key`    | Chave substituta         |
| `facility_id`     | Chave natural            |
| `facility_name`   | Nome da instalação       |
| `facility_type`   | Tipo da instalação       |
| `city`            | Cidade                   |
| `state`           | Estado                   |
| `latitude`        | Latitude                 |
| `longitude`       | Longitude                |
| `dock_doors`      | Quantidade de docas      |
| `operating_hours` | Horário de funcionamento |

---

### 3.8 `dim_location`

Dimensão opcional criada a partir dos campos de cidade e estado presentes em abastecimentos, incidentes e eventos.

Atributos sugeridos:

| Atributo       | Descrição         |
| -------------- | ----------------- |
| `location_key` | Chave substituta  |
| `city`         | Cidade            |
| `state`        | Estado            |
| `country`      | País              |
| `region`       | Região geográfica |

---

### 3.9 `dim_load_profile`

Dimensão sugerida para agrupar atributos descritivos da carga.

Atributos:

| Atributo           | Descrição                 |
| ------------------ | ------------------------- |
| `load_profile_key` | Chave substituta          |
| `load_type`        | Tipo de carga             |
| `booking_type`     | Modalidade de contratação |
| `load_status`      | Status da carga           |

---

### 3.10 `dim_trip_status`

Dimensão pequena para classificação da viagem.

Atributos:

| Atributo          | Descrição                      |
| ----------------- | ------------------------------ |
| `trip_status_key` | Chave substituta               |
| `trip_status`     | Status da viagem               |
| `status_group`    | Agrupamento analítico opcional |


---

## 4. Tabelas fato

## 4.1 `fact_load`

### Processo

Contratação e registro comercial de cargas.

### Granularidade

> Uma linha representa uma carga registrada.

### Origem

`loads.csv`

### Chaves

| Chave              | Dimensão           |
| ------------------ | ------------------ |
| `customer_key`     | `dim_customer`     |
| `route_key`        | `dim_route`        |
| `load_date_key`    | `dim_date`         |
| `load_profile_key` | `dim_load_profile` |

### Dimensão degenerada

* `load_id`

O identificador da carga permanece na tabela fato, pois possui significado operacional, mas não precisa de uma dimensão própria.

### Métricas

| Métrica               | Tipo     |
| --------------------- | -------- |
| `weight_lbs`          | Aditiva  |
| `pieces`              | Aditiva  |
| `revenue`             | Aditiva  |
| `fuel_surcharge`      | Aditiva  |
| `accessorial_charges` | Aditiva  |
| `total_load_revenue`  | Derivada |

Fórmula sugerida:

```text
total_load_revenue =
    revenue
    + fuel_surcharge
    + accessorial_charges
```

### Indicador de contagem

* `load_count = 1`

---

## 4.2 `fact_trip`

### Processo

Execução operacional de viagens.

### Granularidade

> Uma linha representa uma viagem executada ou registrada.

### Origem

`trips.csv`

### Chaves

| Chave               | Dimensão          |
| ------------------- | ----------------- |
| `driver_key`        | `dim_driver`      |
| `truck_key`         | `dim_truck`       |
| `trailer_key`       | `dim_trailer`     |
| `dispatch_date_key` | `dim_date`        |
| `trip_status_key`   | `dim_trip_status` |

### Dimensões degeneradas

* `trip_id`;
* `load_id`.

O `load_id` permite navegar entre o processo comercial da carga e sua execução, mas deve ser tratado cuidadosamente para não criar relacionamentos fato-fato inadequados na ferramenta de BI.

### Métricas

| Métrica                 | Tipo        |
| ----------------------- | ----------- |
| `actual_distance_miles` | Aditiva     |
| `actual_duration_hours` | Aditiva     |
| `fuel_gallons_used`     | Aditiva     |
| `idle_time_hours`       | Aditiva     |
| `average_mpg`           | Não aditiva |
| `trip_count`            | Aditiva     |

O `average_mpg` não deve ser somado. Para agregações, o consumo consolidado deve ser recalculado:

```text
MPG consolidado =
    soma das milhas
    ÷
    soma dos galões utilizados
```

---

## 4.3 `fact_delivery_event`

### Processo

Execução de coletas e entregas.

### Granularidade

> Uma linha representa um evento logístico de uma viagem.

### Origem

`delivery_events.csv`

### Chaves

| Chave                | Dimensão       |
| -------------------- | -------------- |
| `facility_key`       | `dim_facility` |
| `scheduled_date_key` | `dim_date`     |
| `actual_date_key`    | `dim_date`     |
| `location_key`       | `dim_location` |

### Dimensões degeneradas

* `event_id`;
* `trip_id`;
* `load_id`;
* `event_type`.

O `event_type` pode permanecer diretamente na fato ou ser incorporado a uma junk dimension.

### Métricas e indicadores

| Métrica                     | Tipo     |
| --------------------------- | -------- |
| `detention_minutes`         | Aditiva  |
| `event_count`               | Aditiva  |
| `on_time_event_count`       | Aditiva  |
| `late_event_count`          | Aditiva  |
| `schedule_variance_minutes` | Derivada |

Exemplos:

```text
on_time_event_count =
    1 quando on_time_flag = true
```

```text
late_event_count =
    1 quando on_time_flag = false
```

```text
schedule_variance_minutes =
    actual_datetime - scheduled_datetime
```

A tabela também precisa preservar os timestamps completos de previsão e realização, pois a dimensão data sozinha não representa hora e minuto.

---

## 4.4 `fact_fuel_purchase`

### Processo

Compra de combustível.

### Granularidade

> Uma linha representa uma transação de abastecimento.

### Origem

`fuel_purchases.csv`

### Chaves

| Chave               | Dimensão       |
| ------------------- | -------------- |
| `driver_key`        | `dim_driver`   |
| `truck_key`         | `dim_truck`    |
| `purchase_date_key` | `dim_date`     |
| `location_key`      | `dim_location` |

### Dimensões degeneradas

* `fuel_purchase_id`;
* `trip_id`;
* `fuel_card_number`.

O número do cartão deve ser mascarado ou removido da camada de consumo caso seja considerado informação sensível.

### Métricas

| Métrica               | Tipo        |
| --------------------- | ----------- |
| `gallons`             | Aditiva     |
| `total_cost`          | Aditiva     |
| `price_per_gallon`    | Não aditiva |
| `fuel_purchase_count` | Aditiva     |

O preço médio deve ser calculado de forma ponderada:

```text
Preço médio por galão =
    soma do custo total
    ÷
    soma dos galões
```

---

## 4.5 `fact_maintenance`

### Processo

Manutenção da frota.

### Granularidade

> Uma linha representa um registro de manutenção realizado em um caminhão.

### Origem

`maintenance_records.csv`

### Chaves

| Chave                  | Dimensão       |
| ---------------------- | -------------- |
| `truck_key`            | `dim_truck`    |
| `maintenance_date_key` | `dim_date`     |
| `location_key`         | `dim_location` |

### Dimensão degenerada

* `maintenance_id`.

### Atributos descritivos

* `maintenance_type`;
* `service_description`.

Esses atributos podem permanecer na fato, compor uma junk dimension ou originar uma pequena dimensão de manutenção.

### Métricas

| Métrica             | Tipo        |
| ------------------- | ----------- |
| `odometer_reading`  | Não aditiva |
| `labor_hours`       | Aditiva     |
| `labor_cost`        | Aditiva     |
| `parts_cost`        | Aditiva     |
| `total_cost`        | Aditiva     |
| `downtime_hours`    | Aditiva     |
| `maintenance_count` | Aditiva     |

---

## 4.6 `fact_safety_incident`

### Processo

Registro de ocorrências de segurança.

### Granularidade

> Uma linha representa um incidente de segurança.

### Origem

`safety_incidents.csv`

### Chaves

| Chave               | Dimensão       |
| ------------------- | -------------- |
| `driver_key`        | `dim_driver`   |
| `truck_key`         | `dim_truck`    |
| `incident_date_key` | `dim_date`     |
| `location_key`      | `dim_location` |

### Dimensões degeneradas

* `incident_id`;
* `trip_id`.

### Atributos de classificação

* `incident_type`;
* `at_fault_flag`;
* `injury_flag`;
* `preventable_flag`.

Esses atributos são candidatos a uma junk dimension de segurança.

### Métricas

| Métrica                      | Tipo    |
| ---------------------------- | ------- |
| `vehicle_damage_cost`        | Aditiva |
| `cargo_damage_cost`          | Aditiva |
| `claim_amount`               | Aditiva |
| `incident_count`             | Aditiva |
| `injury_incident_count`      | Aditiva |
| `preventable_incident_count` | Aditiva |
| `at_fault_incident_count`    | Aditiva |

---

## 5. Matriz de relacionamento

A matriz abaixo mostra quais dimensões são compartilhadas entre os processos.

| Dimensão         | Carga | Viagem | Evento | Combustível | Manutenção | Segurança |
| ---------------- | :---: | :----: | :----: | :---------: | :--------: | :-------: |
| Data             |   X   |    X   |    X   |      X      |      X     |     X     |
| Cliente          |   X   |        |        |             |            |           |
| Rota             |   X   |        |        |             |            |           |
| Motorista        |       |    X   |        |      X      |            |     X     |
| Caminhão         |       |    X   |        |      X      |      X     |     X     |
| Carreta          |       |    X   |        |             |            |           |
| Instalação       |       |        |    X   |             |            |           |
| Localização      |       |        |    X   |      X      |      X     |     X     |
| Perfil da carga  |   X   |        |        |             |            |           |
| Status da viagem |       |    X   |        |             |            |           |

---

## 6. Tratamento dos arquivos agregados

### `driver_monthly_metrics.csv`

Granularidade:

> Uma linha por motorista por mês.

O arquivo contém métricas mensais já agregadas, como:

* viagens concluídas;
* milhas;
* receita;
* consumo de combustível;
* pontualidade;
* tempo ocioso.

Esses indicadores podem ser recalculados a partir das tabelas fato detalhadas. Portanto, o arquivo não deve ser tratado automaticamente como fonte principal.

Possíveis usos:

* validação dos cálculos do Data Warehouse;
* comparação de resultados;
* construção de uma tabela agregada de desempenho, caso exista requisito de performance.

---

### `truck_utilization_metrics.csv`

Granularidade:

> Uma linha por caminhão por mês.

Possíveis usos:

* validação das métricas calculadas;
* snapshot mensal de utilização da frota;
* tabela agregada para consultas executivas.

Caso seja implementada como fato, o nome sugerido seria:

```text
fact_truck_monthly_snapshot
```

Entretanto, deve-se evitar duplicar indicadores que podem ser calculados diretamente a partir das tabelas transacionais.

---

## 7. Relacionamento entre carga e viagem

No conjunto atual:

* `loads.csv` possui 85.410 cargas;
* `trips.csv` possui 85.410 viagens;
* cada viagem referencia um `load_id`.

Isso sugere uma correspondência de uma carga para uma viagem no dataset atual.

Apesar disso, `fact_load` e `fact_trip` foram mantidas separadas porque representam processos diferentes:

* `fact_load`: contratação e resultado comercial;
* `fact_trip`: execução operacional.

A relação entre fatos não deve ser criada diretamente no modelo sem avaliar o comportamento da ferramenta analítica.

As análises integradas podem utilizar:

* uma dimensão comum derivada da carga;
* o identificador degenerado `load_id`;
* uma bridge table, caso a cardinalidade futura se torne muitos para muitos;
* uma tabela fato consolidada, somente se o negócio confirmar que carga e viagem são permanentemente equivalentes.

---

## 8. KPIs suportados

### Cargas

* quantidade de cargas;
* peso transportado;
* quantidade de volumes;
* receita total;
* receita média por carga;
* receita por cliente;
* receita por rota;
* participação por modalidade de contratação.

### Viagens

* quantidade de viagens;
* milhas percorridas;
* duração média;
* tempo ocioso;
* consumo total de combustível;
* eficiência média de combustível;
* viagens por motorista;
* viagens por caminhão.

### Eventos

* quantidade de coletas;
* quantidade de entregas;
* taxa de pontualidade;
* tempo médio de retenção;
* atraso médio;
* desempenho por instalação.

### Combustível

* custo total;
* consumo total;
* preço médio ponderado;
* custo por caminhão;
* custo por motorista;
* custo por viagem.

### Manutenção

* custo total de manutenção;
* custo de peças;
* custo de mão de obra;
* tempo de indisponibilidade;
* quantidade de manutenções;
* custo por caminhão.

### Segurança

* quantidade de incidentes;
* custo total de danos;
* valor total de reclamações;
* taxa de incidentes evitáveis;
* taxa de incidentes com responsabilidade;
* incidentes por motorista;
* incidentes por caminhão.

---

## 10. Pontos que exigem validação

1. Carga e viagem são permanentemente uma relação um para um?

2. Uma viagem futura poderá transportar múltiplas cargas?

3. A receita deve ser analisada no momento da contratação da carga ou após a conclusão da viagem?

4. `on_time_flag` utiliza qual tolerância em relação ao horário previsto?

5. `detention_minutes` representa espera total, espera acima da franquia ou outro cálculo?

6. `load_status` e `trip_status` devem possuir histórico?

7. As localizações textuais devem formar uma dimensão única ou permanecer nas respectivas fatos?

8. Os arquivos mensais serão usados apenas para validação ou também como snapshots oficiais?

9. O `average_mpg` da origem deve ser preservado ou sempre recalculado?

10. Dados pessoais e identificadores sensíveis serão removidos da camada de consumo?

---
