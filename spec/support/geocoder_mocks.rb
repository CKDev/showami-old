Geocoder.configure(lookup: :test)

Geocoder::Lookup::Test.add_stub(
  "600 S Broadway Unit 200 Denver, CO 80209", [{
    "latitude"        => 39.70556,
    "longitude"       => -104.987236,
    "address"         => "600 S Broadway Unit 200",
    "state"           => "Colorado",
    "state_code"      => "CO",
    "country"         => "United States",
    "country_code"    => "US"
  }])

Geocoder::Lookup::Test.set_default_stub(
  [{
    "latitude"        => 39.70556,
    "longitude"       => -104.987236,
    "address"         => "600 S Broadway Unit 200",
    "state"           => "Colorado",
    "state_code"      => "CO",
    "country"         => "United States",
    "country_code"    => "US"
  }])
