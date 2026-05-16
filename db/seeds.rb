[
  Package,
  Animal,
  TripDestination,
  TripGroup,
  Trip,
  ItemRequest,
  PersonSize,
  Person,
  Location,
  Region,
  ItemCategory,
  MenuItem,
  VisitSummary
].each(&:destroy_all)

[
  "City", # 0
  "REGION 1", # 1
  "REGION 2 AND SURROUNDINGS", # 2
  "REGION 3", # 3
  "REGION 4", # 4
  "REGION 5, 6", # 5
  "REGION 7", # 6
  "REGION 8, 9, 10", # 7
  "REGION 11, 12", # 8
  "REGION 13", # 9
  "REGION 14, 15, 16", # 10
  "REGION 17, 18", # 11
  "REGION 19", # 12
  "REGION 20", # 13
  "REGION 21, 22, 23, 24", # 14
  "REGION 25", # 15
  "REGION 26, 27", # 16
  "REGION 28" # 17
].each do |region|
  Region.create(name: region.downcase.titleize)
end

regions = Region.all

[
  {name: "Location 1", region: regions[13], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 2", region: regions[13], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 3", region: regions[17], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 4 - garage", region: regions[14], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 5", region: regions[1], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 6 - small blue house", region: regions[1], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 7 - trailer", region: regions[1], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 8 - tent", region: regions[1], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 9 - new location", region: regions[1], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 10 - tunnel", region: regions[1], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 11 - new location", region: regions[1], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 12 - vacant developer space", region: regions[1], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 13 - parking (to verify)", region: regions[1], latitude: 39.433329, longitude: -31.209797},
  {name: "Location 14 - clinic", region: regions[1], latitude: 39.433329, longitude: -31.209797}
].each do |location|
  Location.create(location)
end

locations = Location.includes(:people).all

[
  {first_name: "Biecława", code: "001", location: locations[0], requests_status: "green", phone_number: "123456789"},
  {first_name: "Radomił", code: "002", location: locations[0], requests_status: "green", phone_number: "321654987"},
  {first_name: "Mezamir", code: "003", location: locations[0], requests_status: "green", phone_number: "456789123"},
  {first_name: "Bratumiła", code: "004", location: locations[1], requests_status: "green", phone_number: "987654321"},
  {first_name: "Janisław", code: "005", location: locations[1], requests_status: "green", phone_number: "789456123"},
  {first_name: "Mojmira", code: "006", location: locations[2], requests_status: "green", phone_number: "654123789"},
  {first_name: "Nawoja", code: "007", location: locations[2], requests_status: "green"},
  {first_name: "Pomir", code: "008", location: locations[3], requests_status: "green"},
  {first_name: "Misław", code: "009", location: locations[3], requests_status: "green"},
  {first_name: "Radowit", code: "010", location: locations[3], requests_status: "green"},
  {first_name: "Wojemił", code: "011", location: locations[4], requests_status: "green"}
].each do |person|
  Person.create(person)
end

[
  {author: "Dwight Schrute", content: "Dzisiaj byłem w tej lokalizacji. Wszystko w porządku 🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨. Bacon ipsum dolor amet brisket cow pork chop ground round. Ham pork venison swine tri-tip frankfurter strip steak cow", visit_date: 1.month.ago, location: locations[0]},
  {author: "Jim Halpert", content: "Dzisiaj byłem w tej lokalizacji 🐨🦁🙊🐨🦁🙊🐨🦁🙊. Wszystko w porządku. Bacon ipsum dolor amet brisket cow pork chop ground round. Ham pork venison swine tri-tip frankfurter strip steak cowBacon ipsum dolor amet brisket cow pork chop ground round. Ham pork venison swine tri-tip frankfurter strip steak cow", visit_date: 1.week.ago, location: locations[0]},
  {author: "Pam Beasly", content: "Dzisiaj byłem w tej lokalizacji 🐨🦁🙊🐨🦁🙊. Wszystko w porządku.", visit_date: 2.week.ago, location: locations[1]},
  {author: "Michael Scott", content: "Dzisiaj byłem w tej lokalizacji 🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨🐶🐨. Wszystko w porządku. Bacon ipsum dolor amet brisket cow pork chop ground round. Ham pork venison swine tri-tip frankfurter strip steak cowBacon ipsum dolor amet brisket cow pork chop ground round. Ham pork venison swine tri-tip frankfurter strip steak cow", visit_date: 3.week.ago, location: locations[2]},
  {author: "Dwight Schrute", content: "Dzisiaj byłem w tej lokalizacji 🦁🙊🦁🙊🦁🙊🦁🙊. Wszystko w porządku 🦁🙊🦁🙊🦁🙊🦁🙊.", visit_date: Date.yesterday, location: locations[3]}
].each do |visit_summary|
  vs = VisitSummary.new(visit_summary)
  vs.people = vs.location.active_people
  vs.save!
end

[
  {name: "Buty", icon_name: "shoe", available_sizes: (32..46).to_a},
  {name: "Spodnie", icon_name: "pants", available_sizes: %w[XXL XL L M S]},
  {name: "Kurtka", icon_name: "jacket", available_sizes: %w[XXL XL L M S]},
  {name: "Czapka", icon_name: "hat", available_sizes: []},
  {name: "Szalik", icon_name: "scarf", available_sizes: []},
  {name: "Rękawiczki", icon_name: "gloves", available_sizes: []},
  {name: "Koszulka", icon_name: "shirt", available_sizes: %w[L M S]},
  {name: "Sweter", icon_name: "sweater", available_sizes: %w[L M S]},
  {name: "Kalesony", icon_name: "underpants", available_sizes: %w[L M S]},
  {name: "Bielizna", icon_name: "underwear", available_sizes: %w[L M S]},
  {name: "Skarpety", icon_name: "socks", available_sizes: (32..46).to_a},
  {name: "Śpiwór", icon_name: "sleepingbag", available_sizes: []},
  {name: "Kosmetyki", icon_name: "cosmetics", available_sizes: []},
  {name: "Namiot", icon_name: "tent", available_sizes: []},
  {name: "Inne", icon_name: "other", available_sizes: []}
].each do |category|
  ItemCategory.create(category)
end

[
  {item_type: "external", priority_order: 1, name: "Google", url: "https://google.com", is_active: true},
  {item_type: "internal", priority_order: 2, name: "Search", url: "/search", is_active: true},
  {item_type: "internal", priority_order: 3, name: "Wyjazdy", url: "/trips", is_active: true}
].each do |menu_item|
  MenuItem.create(menu_item)
end

Person.all.each do |person|
  ItemCategory.all.filter(&:sizeable?).each do |category|
    PersonSize.create(person:, item_category: category, size: category.available_sizes.sample)
  end
end

[{
  name: "Stowarzyszenie Dobroczynne 'Betlejem' Dom Łazarza",
  address: "ul. Nowogródzka 8",
  conditions: "Brak warunków wstępnych, można przyjść “z ulicy”",
  timings: "Nie ma ustalonych godzin",
  items_offered: "Odzież (tylko męska)"
},
  {
    name: "Fundacja Po pierwsze CZŁOWIEK",
    address: "ul. Woronicza 3b",
    conditions: "Można przyjść “z ulicy”, ale trzeba zapisać się na termin",
    timings: "Poniedziałek - sobota, 11:30 - 14:00",
    items_offered: "Odzież (tylko męska), pościel, artykuły higieniczne i chemiczne, pościele, ręczniki, drobne AGD; w ww. godzinach można również dostać obiad"
  },
  {
    name: "Dzieło Pomocy św. Ojca Pio",
    address: "ul. Smoleńsk 4",
    conditions: "Garderoba czynna dla osób korzystających z łaźni, w godzinach jej funkcjonowania",
    timings: "Dla panów: poniedziałek: 9:00 - 15:00, wtorek i piątek: 11:40 - 15:00, środa: 9:00 - 15:00. Dla pań: wtorek i piątek 9:00 - 11:40",
    items_offered: "Łaźnia, odzież"
  },
  {
    name: "Przytulisko dla bezdomnych mężczyzn im. Brata Alberta",
    address: "ul. Skawińska 6",
    conditions: "Garderoba czynna wyłącznie dla osób korzystających z łaźni, w godzinach jej funkcjonowania",
    timings: "Dla panów: wtorek-środa i piątek-sobota - 8:30-13:30. Dla pań: czwartek 8:30-13:30",
    items_offered: "Łaźnia, odzież"
  },
  {
    name: "Zespół charytatywny św. Jana Kantego",
    address: "ul. Jabłonkowska 18",
    conditions: "Wymagana trzeźwość",
    timings: "Czwartki 17:30 - 19:30, wybrane wtorki 10:30-12:30. Poza dyżurami potrzebujący mogą umawiać się w indywidualnych terminach pisząc maila na kanty.caritas@onet.pl",
    items_offered: "Odzież, obuwie i akcesoria dziecięce, damskie i męskie, artykuły higieniczne i chemiczne, tekstylia, pościele, ręczniki, a także zabawki, artykuły dziecięce czy drobne AGD"
  }].each do |help_institution|
  HelpInstitution.create(help_institution)
end

AdminUser.create(email: "admin@example.com", password: "pass1234", first_name: "Admin", last_name: "Adminowski")

[
  {
    date: "2025-01-01",
    groups: [
      {
        volunteers: ["Blanche*", "Harold", "Stanley", "Stella"],
        destinations: [
          {location_id: locations[0].id},
          {location_id: locations[1].id}
        ]
      },
      {
        volunteers: ["Zbyszek*", "Leszek", "Rysiek"],
        destinations: [
          {location_id: locations[2].id},
          {location_id: locations[3].id},
          {location_id: locations[4].id}
        ]
      },
      {
        volunteers: ["Liara", "Garrus", "Ashley", "Kaidan", "Miranda"],
        destinations: [
          {location_id: locations[5].id},
          {location_id: locations[6].id},
          {location_id: locations[7].id},
          {location_id: locations[8].id}
        ]
      }
    ]
  }
].each do |trip_data|
  trip = Trip.create(
    date: trip_data[:date],
    admin_user_id: AdminUser.all.sample.id,
    source_spreadsheet_url: "https://spreadsheet_sample",
    active: true
  )

  trip_data[:groups].each_with_index do |group_data, index|
    trip_group = TripGroup.create(
      volunteers: group_data[:volunteers],
      trip_id: trip.id,
      number: index + 1
    )

    group_data[:destinations].each do |destination_data|
      TripDestination.create(
        trip_group_id: trip_group.id,
        location_id: destination_data[:location_id],
        soups: 1,
        waters: 1,
        provisions: 1,
        books: 2,
        additional_info: "Dać znać telefonicznie, wyjeżdżając, że będziemy i pytać gdzie są"
      )
    end
  end
end

[
  {
    date: "2022-01-01",
    groups: [
      {
        volunteers: ["Blanche*", "Harold", "Stanley", "Stella"],
        destinations: [
          {location_id: locations[0].id},
          {location_id: locations[1].id}
        ]
      },
      {
        volunteers: ["Zbyszek*", "Leszek", "Rysiek"],
        destinations: [
          {location_id: locations[2].id},
          {location_id: locations[3].id},
          {location_id: locations[4].id}
        ]
      },
      {
        volunteers: ["Liara", "Garrus", "Ashley", "Kaidan", "Miranda"],
        destinations: [
          {location_id: locations[5].id},
          {location_id: locations[6].id},
          {location_id: locations[7].id},
          {location_id: locations[8].id}
        ]
      }
    ]
  }
].each do |trip_data|
  trip = Trip.create(
    date: trip_data[:date],
    admin_user_id: AdminUser.all.sample.id,
    source_spreadsheet_url: "https://spreadsheet_sample",
    active: false
  )

  trip_data[:groups].each_with_index do |group_data, index|
    trip_group = TripGroup.create(
      volunteers: group_data[:volunteers],
      trip_id: trip.id,
      number: index + 1
    )

    group_data[:destinations].each do |destination_data|
      TripDestination.create(
        trip_group_id: trip_group.id,
        location_id: destination_data[:location_id],
        soups: 1,
        waters: 1,
        provisions: 1,
        books: 2,
        sandwiches: 1,
        additional_info: "Dać znać telefonicznie, wyjeżdżając, że będziemy i pytać gdzie są"
      )
    end
  end
end
