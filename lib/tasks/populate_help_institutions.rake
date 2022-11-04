namespace :db do
  desc "Populate database with help institutions"
  task populate_help_institutions: :environment do
    help_institutions_data = [
      {
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
      }
    ]

    help_institutions_data.each do |help_institution|
      HelpInstitution.create(help_institution)
    end

    puts "Help institutions have been populated!"
  end
end
