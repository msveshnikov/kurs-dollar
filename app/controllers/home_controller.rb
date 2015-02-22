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

      make_forecast
      f.xAxis(categories: @forecast.map { |v| v.date.to_s[0..9] })

      f.series(name: "Доллар", color: "#7cad31", yAxis: 0, data: @rates.map { |v| v.dollar })
      f.series(name: "Прогноз", dashStyle: 'dot', color: "#7cad31", marker: { symbol: 'circle' }, yAxis: 0, data: @forecast.map { |v| v.dollar })

      f.series(name: "Евро", color: "#7CB5EC", marker: { symbol: 'circle' }, yAxis: 0, data: @rates.map { |v| v.euro })
      f.series(name: "Прогноз", dashStyle: 'dot', color: "#7CB5EC", marker: { symbol: 'circle' }, yAxis: 0, data: @forecast.map { |v| v.euro })

      f.series(name: "Нефть", color: "#42042B", marker: { symbol: 'circle' }, yAxis: 0, data: @rates.map { |v| v.oil })
      f.series(name: "Прогноз", dashStyle: 'dot', color: "#42042B", marker: { symbol: 'circle' }, yAxis: 0, data: @forecast.map { |v| v.oil })

      f.yAxis [{ title: { text: "Курс доллара/евро", margin: 10 } }]

      f.legend(width: 320, floating: true,
               align: 'left', x: 0, y: 0, itemWidth: 80, borderWidth: 1)
      f.chart({ marginBottom: 140, defaultSeriesType: "line" })
    end
  end

  def make_forecast
    @forecast=@rates.clone
    @forecast << OpenStruct.new(date: "2015-02-23", dollar: 65.0, euro: 70, oil: 55)
    @forecast << OpenStruct.new(date: "2015-02-24", dollar: 63.0, euro: 72, oil: 55)
    @forecast << OpenStruct.new(date: "2015-02-25", dollar: 61.0, euro: 73, oil: 55)
    @forecast.each_with_index { |s, i| s.dollar=nil if i<@rates.size-1 }
  end
end
