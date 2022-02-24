ALTER TABLE lipas.metadata DROP COLUMN type_code_list;
ALTER TABLE lipas.metadata ADD COLUMN type_codes_summer jsonb;
ALTER TABLE lipas.metadata ADD COLUMN type_codes_winter jsonb;
ALTER TABLE lipas.metadata ADD COLUMN type_codes_all_year jsonb;

INSERT INTO lipas.metadata (
	type_codes_summer,
	type_codes_winter,
	type_codes_all_year
) VALUES (
	'[205, 203, 5150, 3220, 3230, 4451, 4452]',
	'[4640, 4630, 1520, 1530, 1550, 1510, 3240, 4402, 4440]',
	'[206,301,304,302,202,1120,1130,6210,1180,4710,4720,204,207,4412,4411,4403,4405,4401,4404,4430,101,102,1110]'
);
