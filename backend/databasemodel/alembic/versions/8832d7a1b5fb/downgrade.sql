ALTER TABLE lipas.abstract ALTER COLUMN "type_typeCode" DROP NOT NULL;
ALTER TABLE lipas.abstract ALTER COLUMN type_name DROP NOT NULL;

ALTER TABLE lipas.luistelukentta
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.hiihtomaa
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.kilpahiihtokeskus
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.kaukalo
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.luistelureitti
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.tekojaakentta
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.ruoanlaittopaikka
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.laavu_kota_tai_kammi
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.ulkoilumaja_hiihtomaja
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.tupa
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.telttailu_leiriytyminen
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.lahiliikuntapaikka
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.ulkokuntoilupaikka
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.koiraurheilualue
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.frisbeegolfrata
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.ulkokiipeilyseina
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.kiipeilykallio
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.rantautumispaikka
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.veneilyn_palvelupaikka
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.kalastusalue_paikka
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.koskimelontakeskus
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.luontotorni
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.opastuspiste
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.uimaranta
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.uimapaikka
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.talviuintipaikka
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.lahipuisto
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.ulkoilupuisto
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.liikuntapuisto
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.latu
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.koirahiihtolatu
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.melontareitti
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.vesiretkeilyreitti
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.pyorailyreitti
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.maastopyorailyreitti
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.kavelyreitti_ulkoilureitti
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.retkeilyreitti
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.kuntorata
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.luontopolku
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE lipas.hevosreitti
ALTER COLUMN geom DROP NOT NULL;

ALTER TABLE kooste.lipas_pisteet
ADD status text DEFAULT NULL;

ALTER TABLE kooste.lipas_pisteet
DROP COLUMN visibility;

-- VAIHDA NAIHIN boolean yms tilalle SET !!
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN toilet SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN shower SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "changingRooms" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN ligthing SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "restPlacesCount" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "skiTrackTraditional" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "skiTrackFreestyle" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "litRouteLengthKm" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "routeLengthKm" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN pier SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "otherPlatforms" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "accessibilityInfo" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN kiosk SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "skiService" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "equipmentRental" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN sauna SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN playground SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "exerciseMachines" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "infoFi" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "trackLengthM" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "altitudeDifference" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "climbingWallWidthM" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "climbingWallHeightM" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "climbingRoutesCount" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "holesCount" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "boatLaunchingSpot" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "iceClimbing" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "iceReduction" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN range SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "trackType" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN "additionalInfo" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_pisteet ALTER COLUMN images SET DEFAULT NULL;

ALTER TABLE kooste.lipas_viivat
ADD status text DEFAULT NULL;

ALTER TABLE kooste.lipas_viivat
DROP visibility;

ALTER TABLE kooste.lipas_viivat ALTER COLUMN toilet SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "restPlacesCount" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "skiTrackTraditional" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "skiTrackFreestyle" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "litRouteLengthKm" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "routeLengthKm" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "accessibilityInfo" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "exerciseMachines" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "infoFi" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "shootingPositionsCount" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN "additionalInfo" SET DEFAULT NULL;
ALTER TABLE kooste.lipas_viivat ALTER COLUMN images SET DEFAULT NULL;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
ALTER COLUMN visibility SET NOT NULL;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
RENAME COLUMN visibility TO nakyvyys;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
ALTER COLUMN name DROP NOT NULL;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
RENAME COLUMN name TO nimi;

ALTER TABLE kooste.tamperewfs_luonnonmuistomerkit
RENAME COLUMN "infoFi" TO kohteenkuvaus1;

ALTER TABLE kooste.tamperewfs_luontopolkurastit
ALTER COLUMN visibility SET NOT NULL;

ALTER TABLE kooste.tamperewfs_luontopolkurastit
RENAME COLUMN visibility TO nakyvyys;

ALTER TABLE kooste.tamperewfs_luontopolkurastit
ALTER COLUMN name DROP NOT NULL;

ALTER TABLE kooste.tamperewfs_luontopolkurastit
RENAME COLUMN name TO nimi;

ALTER TABLE kooste.tamperewfs_luontopolkurastit
RENAME COLUMN "infoFi" TO kohteenkuvaus;

ALTER TABLE kooste.tamperewfs_luontopolkurastit
RENAME COLUMN "additionalInfo" TO lisatietoja;

ALTER TABLE kooste.tamperewfs_luontopolkureitit
ALTER COLUMN visibility SET NOT NULL;

ALTER TABLE kooste.tamperewfs_luontopolkureitit
RENAME COLUMN visibility TO nakyvyys;

ALTER TABLE kooste.tamperewfs_luontopolkureitit
ALTER COLUMN name DROP NOT NULL;

ALTER TABLE kooste.tamperewfs_luontopolkureitit
RENAME COLUMN name TO nimi;

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
ALTER COLUMN visibility SET NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
RENAME COLUMN visibility TO nakyvyys;

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
ALTER COLUMN name DROP NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
RENAME COLUMN name TO kohdenimi;

ALTER TABLE kooste.museovirastoarcrest_rkykohteet
RENAME COLUMN www TO url;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
ADD laji text;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
ALTER COLUMN visibility SET NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
RENAME COLUMN visibility TO nakyvyys;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
ALTER COLUMN name DROP NOT NULL;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
RENAME COLUMN name TO kohdenimi;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
RENAME COLUMN "cityName" TO kunta;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
RENAME COLUMN type_name TO tyyppi;

ALTER TABLE kooste.museovirastoarcrest_muinaisjaannokset
RENAME COLUMN www TO url;

GRANT SELECT
ON TABLE kooste.tamperewfs_metadata
TO tarmo_read;

GRANT SELECT
ON TABLE kooste.metadata
TO tarmo_read;
