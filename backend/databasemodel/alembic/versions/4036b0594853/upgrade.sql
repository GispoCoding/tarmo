DELETE FROM kooste.osm_metadata;
INSERT INTO kooste.osm_metadata (tags_to_include, tags_to_exclude)
VALUES (
    '{"amenity": ["parking", "toilets"],
	"tourism": ["camp_site", "caravan_site", "chalet", "guest_house", "hostel", "hotel", "motel", "museum", "viewpoint", "wilderness_hut"],
	"leisure": ["bird_hide", "sauna"],
	"building": ["church"]}',
    '{"access": ["private", "permit"], "shelter_type": ["public_transport"]}'
    );
