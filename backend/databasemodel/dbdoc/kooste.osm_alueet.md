# kooste.osm_alueet

## Description

## Columns

| Name | Type | Default | Nullable | Children | Parents | Comment |
| ---- | ---- | ------- | -------- | -------- | ------- | ------- |
| id | text |  | false |  |  |  |
| osm_id | bigint |  | false |  |  |  |
| osm_type | text |  | false |  |  |  |
| geom | geometry(Polygon,4326) |  | false |  |  |  |
| tarmo_category | text | 'Pysäköinti'::text | true |  |  |  |
| type_name | text | 'Pysäköintialue'::text | true |  |  |  |
| tags | jsonb |  | true |  |  |  |
| deleted | boolean | false | false |  |  |  |

## Constraints

| Name | Type | Definition |
| ---- | ---- | ---------- |
| osm_alueet_pk | PRIMARY KEY | PRIMARY KEY (id) |
| osm_alueet_osm_id_osm_type_key | UNIQUE | UNIQUE (osm_id, osm_type) |

## Indexes

| Name | Definition |
| ---- | ---------- |
| osm_alueet_pk | CREATE UNIQUE INDEX osm_alueet_pk ON kooste.osm_alueet USING btree (id) |
| osm_alueet_osm_id_osm_type_key | CREATE UNIQUE INDEX osm_alueet_osm_id_osm_type_key ON kooste.osm_alueet USING btree (osm_id, osm_type) |
| osm_alueet_deleted_idx | CREATE INDEX osm_alueet_deleted_idx ON kooste.osm_alueet USING btree (deleted) |
| osm_alueet_tarmo_category_idx | CREATE INDEX osm_alueet_tarmo_category_idx ON kooste.osm_alueet USING btree (tarmo_category) |

## Relations

![er](kooste.osm_alueet.svg)

---

> Generated by [tbls](https://github.com/k1LoW/tbls)
