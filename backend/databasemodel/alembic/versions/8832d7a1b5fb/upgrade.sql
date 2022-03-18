ALTER TABLE lipas.abstract ALTER COLUMN "type_typeCode" SET NOT NULL;
ALTER TABLE lipas.abstract ALTER COLUMN type_name SET NOT NULL;

ALTER TABLE lipas.luistelukentta
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.hiihtomaa
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.kilpahiihtokeskus
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.kaukalo
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.luistelureitti
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.tekojaakentta
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.ruoanlaittopaikka
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.laavu_kota_tai_kammi
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.ulkoilumaja_hiihtomaja
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.tupa
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.telttailu_leiriytyminen
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.lahiliikuntapaikka
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.ulkokuntoilupaikka
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.koiraurheilualue
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.frisbeegolfrata
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.ulkokiipeilyseina
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.kiipeilykallio
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.rantautumispaikka
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.veneilyn_palvelupaikka
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.kalastusalue_paikka
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.koskimelontakeskus
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.luontotorni
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.opastuspiste
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.uimaranta
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.uimapaikka
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.talviuintipaikka
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.lahipuisto
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.ulkoilupuisto
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.liikuntapuisto
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.latu
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.koirahiihtolatu
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.melontareitti
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.vesiretkeilyreitti
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.pyorailyreitti
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.maastopyorailyreitti
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.kavelyreitti_ulkoilureitti
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.retkeilyreitti
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.kuntorata
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.luontopolku
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE lipas.hevosreitti
ALTER COLUMN geom SET NOT NULL;

ALTER TABLE kooste.lipas_pisteet
DROP COLUMN status;

ALTER TABLE kooste.lipas_pisteet
ADD visibility boolean DEFAULT True;

ALTER TABLE kooste.lipas_pisteet ALTER COLUMN toilet DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN shower DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "changingRooms" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN ligthing DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "restPlacesCount" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "skiTrackTraditional" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "skiTrackFreestyle" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "litRouteLengthKm" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "routeLengthKm" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN pier DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "otherPlatforms" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "accessibilityInfo" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN kiosk DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "skiService" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "equipmentRental" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN sauna DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN playground DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "exerciseMachines" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "infoFi" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "trackLengthM" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "altitudeDifference" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "climbingWallWidthM" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "climbingWallHeightM" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "climbingRoutesCount" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "holesCount" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "boatLaunchingSpot" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "iceClimbing" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "iceReduction" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN range DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "trackType" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "additionalInfo" DROP DEFAULT;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN images DROP DEFAULT;

ALTER TABLE kooste.lipas_viivat
DROP COLUMN status;

ALTER TABLE kooste.lipas_viivat
ADD visibility boolean DEFAULT True;

ALTER TABLE kooste.lipas_viivat ALTER COLUMN toilet DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "restPlacesCount" DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "skiTrackTraditional" DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "skiTrackFreestyle" DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "litRouteLengthKm" DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "routeLengthKm" DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "accessibilityInfo" DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "exerciseMachines" DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "infoFi" DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "shootingPositionsCount" DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "additionalInfo" DROP DEFAULT;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN images DROP DEFAULT;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
ALTER COLUMN nakyvyys DROP NOT NULL;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
RENAME COLUMN nakyvyys TO visibility;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
ALTER COLUMN nimi SET NOT NULL;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
RENAME COLUMN nimi TO name;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
RENAME COLUMN kohteenkuvaus1 TO "infoFi";

ALTER TABLE kooste.tamperewfs_luontopolkurastit
ALTER COLUMN nakyvyys DROP NOT NULL;

ALTER TABLE kooste.tamperewfs_luontopolkurastit
RENAME COLUMN nakyvyys TO visibility;

ALTER TABLE kooste.tamperewfs_luontopolkurastit
ALTER COLUMN nimi SET NOT NULL;

ALTER TABLE kooste.tamperewfs_luontopolkurastit
RENAME COLUMN nimi TO name;

ALTER TABLE kooste.tamperewfs_luontopolkurastit
RENAME COLUMN kohteenkuvaus TO "infoFi";

ALTER TABLE kooste.tamperewfs_luontopolkurastit
DROP COLUMN lisatietoja;

ALTER TABLE kooste.tamperewfs_luontopolkureitit
ALTER COLUMN nakyvyys DROP NOT NULL;

ALTER TABLE kooste.tamperewfs_luontopolkureitit
RENAME COLUMN nakyvyys TO visibility;

ALTER TABLE kooste.tamperewfs_luontopolkureitit
ALTER COLUMN nimi SET NOT NULL;

ALTER TABLE kooste.tamperewfs_luontopolkureitit
RENAME COLUMN nimi TO name;

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
ALTER COLUMN nakyvyys DROP NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
RENAME COLUMN nakyvyys TO visibility;

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
ALTER COLUMN kohdenimi SET NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
RENAME COLUMN kohdenimi TO name;

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
RENAME COLUMN url TO www;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
DROP COLUMN laji;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
ALTER COLUMN nakyvyys DROP NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
RENAME COLUMN nakyvyys TO visibility;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
ALTER COLUMN kohdenimi SET NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
RENAME COLUMN kohdenimi TO name;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
RENAME COLUMN kunta TO "cityName";

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
RENAME COLUMN tyyppi TO type_name;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
RENAME COLUMN url TO www;

GRANT DELETE
ON TABLE kooste.tamperewfs_metadata
TO tarmo_read;

GRANT DELETE
ON TABLE kooste.metadata
TO tarmo_read;

ALTER TABLE lipas.metadata
ADD tarmo_categories_summer jsonb;

ALTER TABLE lipas.metadata
ADD tarmo_categories_winter jsonb;

ALTER TABLE lipas.metadata
ADD tarmo_categories_all_year jsonb;

INSERT INTO lipas.metadata (
	tarmo_categories_summer,
	tarmo_categories_winter,
	tarmo_categories_all_year
) VALUES (
	'["Vesillä ulkoilu"]',
	'["Hiihto", "Luistelu"]',
	'["Uinti", "Laavut, majat, ruokailu", "Ulkoilupaikat", "Ulkoiluaktiviteetit", "Ulkoilureitit", "Pyöräily", "Nähtävyydet"]'
);

ALTER TABLE kooste.osm_metadata
ADD osm_types_tarmo_joukkoliikennepysakit jsonb;

INSERT INTO kooste.osm_metadata (osm_types_tarmo_joukkoliikennepysakit) VALUES ('["Bus", "Tram", "Train"]');

ALTER TABLE kooste.metadata
ADD codes_tarmo_hiihto jsonb;

ALTER TABLE kooste.metadata
ADD codes_tarmo_luistelu jsonb;

ALTER TABLE kooste.metadata
ADD codes_tarmo_uinti jsonb;

ALTER TABLE kooste.metadata
ADD codes_tarmo_vesilla_ulkoilu jsonb;

ALTER TABLE kooste.metadata
ADD codes_tarmo_laavut_majat_ruokailu jsonb;

ALTER TABLE kooste.metadata
ADD codes_tarmo_ulkoilupaikat jsonb;

ALTER TABLE kooste.metadata
ADD codes_tarmo_ulkoiluaktiviteetit jsonb;

ALTER TABLE kooste.metadata
ADD codes_tarmo_ulkoilureitit jsonb;

ALTER TABLE kooste.metadata
ADD codes_tarmo_nahtavyydet jsonb;

ALTER TABLE kooste.metadata
ADD codes_tarmo_pyoraily jsonb;

INSERT INTO kooste.metadata (
    codes_tarmo_hiihto,
    codes_tarmo_luistelu,
    codes_tarmo_uinti,
    codes_tarmo_vesilla_ulkoilu,
    codes_tarmo_laavut_majat_ruokailu,
    codes_tarmo_ulkoilupaikat,
    codes_tarmo_ulkoiluaktiviteetit,
    codes_tarmo_ulkoilureitit,
    codes_tarmo_nahtavyydet,
    codes_tarmo_pyoraily
) VALUES (
    '[4402,4440,4630,4640]',
    '[1510,1530,1540,1550]',
    '[3220,3230,3240]',
    '[201,203,205,5150,4451,4452]',
    '[202,206,301,302,304]',
    '[101,102,1110,1120]',
    '[1130,1180,4710,4720,6210]',
    '[207,4401,4403,4404,4405,4430]',
    '[204]',
    '[4411,4412]'
);

ALTER TABLE kooste.lipas_pisteet
ADD tarmo_category text NOT NULL;

ALTER TABLE kooste.lipas_viivat
ADD tarmo_category text NOT NULL;

ALTER TABLE kooste.osm_pisteet
ADD tarmo_category text NOT NULL;

ALTER TABLE kooste.osm_alueet
ADD tarmo_category text NOT NULL;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
ADD tarmo_category text DEFAULT 'Nähtävyydet';

ALTER TABLE kooste.tamperewfs_luontopolkurastit
ADD tarmo_category text DEFAULT 'Ulkoilureitit';

ALTER TABLE kooste.tamperewfs_luontopolkureitit
ADD tarmo_category text DEFAULT 'Ulkoilureitit';

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
ADD tarmo_category text DEFAULT 'Nähtävyydet';

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
ADD tarmo_category text DEFAULT 'Nähtävyydet';

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
ADD type_name text DEFAULT 'Luonnonmuistomerkki';

ALTER TABLE kooste.tamperewfs_luontopolkurastit
ADD type_name text DEFAULT 'Luontopolkurasti';

ALTER TABLE kooste.tamperewfs_luontopolkureitit
ADD type_name text DEFAULT 'Luontopolku';

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
ADD type_name text DEFAULT 'Rakennettu kulttuurikohde';

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
ALTER COLUMN type_name SET DEFAULT 'Muinaisjäännös';
