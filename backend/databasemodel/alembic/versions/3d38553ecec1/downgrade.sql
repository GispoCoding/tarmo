DELETE FROM kooste.osm_metadata;
INSERT INTO kooste.osm_metadata (tags_to_include, tags_to_exclude)
VALUES (
        '{"amenity": ["parking", "bicycle_parking", "bbq", "bench", "cafe", "ice_cream", "recycling", "restaurant", "shelter", "toilets", "waste_basket"],
	"tourism": ["camp_site", "caravan_site", "chalet", "guest_house", "hostel", "hotel", "information", "motel", "museum", "picnic_site", "viewpoint", "wilderness_hut"],
	"leisure": ["bird_hide", "picnic_table", "sauna"],
	"shop": ["kiosk"],
	"building": ["church"]}',
        '{"access": ["private", "permit"]}'
    );
