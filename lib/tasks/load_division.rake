namespace :load_division do
  desc "Load votes"
  task :votes, [:from_date, :to_date] => :environment do |t, args|
    load_votes = JSON.load(open('http://mykolaivvoted.oporaua.org/votes_events'))
    #save_votes = Division.pluck(:date).uniq.to_a.map{|d| d.strftime('%Y-%m-%d')}
    date_votes = load_votes #- save_votes
    date_votes.each do |date|
      divisions = JSON.load(open("http://mykolaivvoted.oporaua.org/votes_events/#{date}"))
      divisions.each do |d|
        date_day = d[0]["date_vote"].nil? ? "" :  DateTime.parse(d[0]["date_vote"]).strftime("%F")
        clok_time = d[0]["date_vote"].nil? ? "" : DateTime.parse(d[0]["date_vote"]).strftime("%T")
        division = Division.find_or_create_by(
            date: date_day,
            number: d[0]["number"],
            name: d[0]["name"],
            clock_time: clok_time,
            result: d[0]["option"]
        )
        division.votes.destroy_all
          votes_mp = []
          p "Adeded deputy voted"
          d[1]["votes"].each do |r|
            votes_mp << r["voter_id"]
            division.votes.create(deputy_id: r["voter_id"], vote: r["result"])
          end
          p "Adeded deputy absent"
          Mp.where.not(deputy_id: votes_mp ).each do |m|
            division.votes.create(deputy_id: m.deputy_id, vote: "absent")
          end
      end
    end
  end
end
