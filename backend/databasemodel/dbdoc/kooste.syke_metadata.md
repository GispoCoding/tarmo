# kooste.syke_metadata

## Description

## Columns

| Name | Type | Default | Nullable | Children | Parents | Comment |
| ---- | ---- | ------- | -------- | -------- | ------- | ------- |
| update_id | bigint |  | false |  |  |  |
| last_modified | timestamp with time zone |  | true |  |  |  |
| layers_to_include | jsonb |  | true |  |  |  |
| url | text | 'https://paikkatieto.ymparisto.fi/arcgis/rest/services/'::text | true |  |  |  |

## Constraints

| Name | Type | Definition |
| ---- | ---- | ---------- |
| syke_metadata_pk | PRIMARY KEY | PRIMARY KEY (update_id) |

## Indexes

| Name | Definition |
| ---- | ---------- |
| syke_metadata_pk | CREATE UNIQUE INDEX syke_metadata_pk ON kooste.syke_metadata USING btree (update_id) |

## Relations

![er](kooste.syke_metadata.svg)

---

> Generated by [tbls](https://github.com/k1LoW/tbls)