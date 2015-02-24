require 'net/http'

class Rate < ActiveRecord::Base

  def self.import
    p "Start importing"
    a = Ox.parse Net::HTTP.get('news.yandex.ru', '/quotes/graph_1.xml')
    b = Ox.parse Net::HTTP.get('news.yandex.ru', '/quotes/graph_1006.xml')
    c = Ox.parse Net::HTTP.get('news.yandex.ru', '/quotes/graph_23.xml')

    usd = {
        time: a.series.x.nodes.first.split(';').map { |v| v.to_i },
        val: a.series.y.nodes.first.split(';').map { |v| v.to_f }
    }

    oil = {
        time: b.series.x.nodes.first.split(';').map { |v| v.to_i },
        val: b.series.y.nodes.first.split(';').map { |v| v.to_f }
    }

    eur = {
        time: c.series.x.nodes.first.split(';').map { |v| v.to_i },
        val: c.series.y.nodes.first.split(';').map { |v| v.to_f }
    }

    @last = Rate.find_by_sql('SELECT * FROM rates ORDER BY date desc LIMIT 1')[0]

    j = 0 # exchange rate for current time
    k = 0
    oil_rate = oil[:val][0]
    eur_rate = eur[:val][0]
    usd[:time].each_with_index do |time, i|
      while ((time > oil[:time][j+1]) rescue false)
        j+= 1
        oil_rate = oil[:val][j]
      end
      while ((time >= eur[:time][k+1]) rescue false)
        k+= 1
        eur_rate = eur[:val][k]
      end
      usd_rate=usd[:val][i]

      if Time.at(time).to_datetime > @last.date
        @rate = Rate.new
        @rate.date=Time.at(time).to_datetime
        @rate.dollar=usd_rate
        @rate.oil=oil_rate
        @rate.euro=eur_rate
        @rate.save!
      end
    end
    p "Stop importing"
  end
end
