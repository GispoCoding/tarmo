ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset ALTER COLUMN tarmo_category SET DEFAULT 'Nähtävyydet';
UPDATE kooste.museovirastoarcrest_muinaisjaannokset SET tarmo_category = 'Nähtävyydet';
