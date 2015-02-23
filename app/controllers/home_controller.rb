# encoding: utf-8
class HomeController < ApplicationController
  before_action :check_for_mobile

  def index
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      params[:month]=1 if !params[:month]
      @rates=Rate.where(date: params[:month].to_i.month.ago..Date.today)
      @dollar=@rates.last.dollar.round(2)
      @euro=@rates.last.euro.round(2)
      @oil=@rates.last.oil
      if params[:month].to_i>6
        n=(params[:month].to_i/6).round
        @rates = (n - 1).step(@rates.size - 1, n).map { |i| @rates[i] }
      end

      make_forecast(@rates.last.date)
      f.xAxis(categories: @forecast.map { |v| v.date.to_s[0..9] })

      f.series(name: "Прогноз", dashStyle: 'dot', color: "#7cad31", marker: { radius: 1 }, yAxis: 0, data: @forecast.map { |v| v.dollar })
      f.series(name: "Доллар", color: "#7cad31", yAxis: 0, data: @rates.map { |v| v.dollar.round(2) })

      f.series(name: "Прогноз", dashStyle: 'dot', color: "#7CB5EC", marker: { radius: 1 }, yAxis: 0, data: @forecast.map { |v| v.euro })
      f.series(name: "Евро", color: "#7CB5EC", marker: { symbol: 'circle' }, yAxis: 0, data: @rates.map { |v| v.euro.round(2) })

      f.series(name: "Прогноз", dashStyle: 'dot', color: "#42042B", marker: { radius: 1 }, yAxis: 0, data: @forecast.map { |v| v.oil })
      f.series(name: "Нефть", color: "#42042B", marker: { symbol: 'circle' }, yAxis: 0, data: @rates.map { |v| v.oil })

      f.yAxis [{ title: { text: "Курс доллара/евро", margin: 10 } }]

      f.legend(floating: true, align: 'left', borderWidth: 0)
      f.chart({ marginBottom: 140, defaultSeriesType: "line" })
    end
  end

  def make_forecast(last)
    @forecast = Marshal.load(Marshal.dump(@rates))
    n=@rates.size
    days=7
    oil=line_trend(@rates[n-days-1].oil, @rates[n-1].oil, days)
    usd=line_trend(@rates[n-days-1].dollar, @rates[n-1].dollar, days)
    eur=line_trend(@rates[n-days-1].euro, @rates[n-1].euro, days)
    (0..days-1).each { |i|
      @forecast << OpenStruct.new(date: last+(i+1).days, dollar: usd[i], euro: eur[i], oil: oil[i])
    }
    @forecast.each_with_index { |s, i| s.dollar=nil if i<n-1 }
    @forecast.each_with_index { |s, i| s.euro=nil if i<n-1 }
    @forecast.each_with_index { |s, i| s.oil=nil if i<n-1 }
  end

  def line_trend(first, last, days)
    dy=last-first
    trend=Array.new(days)
    (0..days-1).each { |i|
      trend[i]=(last+dy*((i+1)/days.to_f)).round(2)
    }
    return trend
  end
end
