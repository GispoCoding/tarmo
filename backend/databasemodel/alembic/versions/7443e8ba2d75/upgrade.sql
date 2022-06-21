DELETE FROM lipas.metadata;

INSERT INTO lipas.metadata (
	type_codes_summer,
	type_codes_winter,
	type_codes_all_year,
	tarmo_category_by_code
) VALUES (
	'[205,203,201,5150,3220,3230,4451,4452]',
	'[4640,4630,1520,1530,1550,1510,3240,4402,4440]',
	'[206,301,304,302,202,1120,1130,6210,1180,4710,4720,204,207,4412,4411,4403,4405,4401,4404,4430,101,102,1110]',
	'{"Hiihto": [4402,4440,4630,4640], "Luistelu": [1510,1520,1530,1550], "Uinti": [3220,3230], "Talviuinti": [3240], "Vesillä ulkoilu": [201,203,205,5150,4451,4452], "Laavut, majat, ruokailu": [202,206,301,302,304], "Ulkoilupaikat": [101,102,1110,1120], "Ulkoiluaktiviteetit": [1130,1180,4710,4720,6210], "Ulkoilureitit": [207,4401,4403,4404,4405,4430], "Pyöräily": [4411,4412], "Nähtävyydet": [204]}'
);
