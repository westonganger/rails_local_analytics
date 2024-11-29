(1.month.ago.to_date..Date.today).each do |date|
  3.times.each do
    TrackedRequestsByDaySite.create!(
      day: date,
      url_hostname: ["example.com", "other-site.com"].sample,
      platform: SecureRandom.hex(3),
      browser_engine: SecureRandom.hex(3),
      total: rand(100)
    )

    TrackedRequestsByDayPage.create!(
      day: date,
      url_hostname: ["example.com", "other-site.com"].sample,
      url_path: ["/", "/foo", "/bar", "/baz"].sample,
      referrer_hostname: ["example.com", "other-site.com"].sample,
      referrer_path:  ["/", "/foo", "/bar", "/baz"].sample,
      total: rand(100)
    )
  end
end
