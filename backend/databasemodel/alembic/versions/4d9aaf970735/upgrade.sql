DELETE FROM kooste.osm_metadata;
INSERT INTO kooste.osm_metadata (
    tags_to_include,
    tags_to_exclude
) VALUES (
    '{"amenity": ["parking", "bicycle_parking"]}',
    '{"access": ["private", "permit"]}'
);
