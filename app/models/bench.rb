class Bench < ApplicationRecord
  extend FriendlyId
  friendly_id :youtubeid, use: :slugged

  has_and_belongs_to_many :games, through: :inputs
  has_and_belongs_to_many :apis, through: :inputs
  has_many :inputs
  has_many :types, -> { distinct }, through: :inputs
  has_many :variations, -> { distinct }, through: :inputs
  has_many :benches_games
  has_one_attached :upload
  
  COLORS    =  ["#3398dc", "#6639b6", "#e64b3b", "#72c02c", "#ebc71d", "#ed4a82", "#b09980", "#22e3be", "#fe541e", "#00BB27", "#4000FF"]
  COLORSRGB =  ["rgba(51,152,220,1)", "rgba(102,57,182,1)", "rgba(230,75,59,1)", "rgba(114,192,44,1)", "rgba(235,199,29,1)"]
  TWENTY    =  [ '#e6194b', '#3cb44b', '#4363d8', '#911eb4', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324', '#fffac8',
     '#800000', '#aaffc3', '#808000', '#000075', '#808080' ]
  FILETYPES = ["MANGO", "OCAT", "HML"]
  
  def self.percentile(values, percentile)
    values_sorted = values.sort
    k = (percentile*(values_sorted.length-1)+1).floor - 1
    f = (percentile*(values_sorted.length-1)+1).modulo(1)

    return values_sorted[k] + (f * (values_sorted[k+1] - values_sorted[k]))
  end

  def self.refresh
    Bench.all.each do |bench|
      if bench.apis.count > 1
        bench.refresh_json_api
      else
        bench.refresh_json
      end
    end
  end
  
  def parse_upload(game_id, variation_id, type_id, bench_id, color, api_id)
    require 'csv'
    parsed = CSV.parse(upload.attachment.download)
    length = parsed.count
    inputs = [
      parsed.each_with_index do |parse, i|
        Input.new(variation_id: variation_id, game_id: game_id, bench_id: self.id, benches_game_id: BenchesGame.where(bench_id: self.id, game_id: game_id).last.id,
                      type_id: type_id, fps: parse[1], frametime: (1000 / parse[1].to_f).round(2),
                      cpu: parse[2].to_f, gpu: parse[2].to_i, color: color, pos: parse[3], apis_bench_id: ApisBench.where(bench_id: self.id, api_id: api_id).last.id, api_id: api_id)
        ActionCable.server.broadcast 'web_notifications_channel', (((i + 0.0) / length) * 100).to_i if i % 100 == 0
      end
    ]
    benches_game = BenchesGame.where(game_id: game_id, bench_id: self.id).last
    self.refresh_json(benches_game)
    # self.refresh_json_api
    ActionCable.server.broadcast 'web_notifications_channel', 100
  end
  
  def parse_upload_hml(game_id, variation_id, type_id, bench_id, color, api_id)
    require 'csv'
    parsed = CSV.parse(upload.attachment.download)
    length = parsed.count
    count = 0
    fps = 0
    gpu = 0
    cpu = 0
    parsed.each_with_index do |parse, i|
      if parsed[0][i] == "Framerate           "
        fps = i
      end
      if parsed[0][i] == "GPU1 usage          " || parsed[0][i] == "GPU usage           "
        gpu = i
      end
      if parsed[0][i] == "CPU usage           "
        cpu = i
      end
    end
      cpu_value = 0
      gpu_value = 0
      parsed.each_with_index do |parse, i|
        unless parse[cpu] == nil || i == 0
          if i % 5 == 0 || i < 5
            cpu_value = parse[cpu].to_f
            gpu_value = parse[gpu].to_i
          end
          #  2.times do 
            Input.create!(variation_id: variation_id, game_id: game_id, bench_id: self.id, benches_game_id: BenchesGame.where(game_id: game_id, bench_id: self.id).last.id,
                          type_id: type_id, fps: parse[fps].to_d, frametime: (1000 / parse[fps].to_f).round(2),
                          cpu: cpu_value, gpu: gpu_value, color: color, pos: count, apis_bench_id: ApisBench.where(bench_id: self.id, api_id: api_id).last.id, api_id: api_id)
            count += 1
          #  end
        end
        ActionCable.server.broadcast 'web_notifications_channel', (((i + 0.0) / length) * 100).to_i if i % 50 == 0
    end
    benches_game = BenchesGame.where(game_id: game_id, bench_id: self.id).last
    self.refresh_json
    # self.refresh_json_api
    ActionCable.server.broadcast 'web_notifications_channel', 100
  end
  
  def parse_upload_mango(game_id, variation_id, type_id, bench_id, color, api_id)
    require 'csv'
    parsed = CSV.parse(upload.attachment.download)
    count = 0
    length = parsed.count
    threads = []
    inputs = []
    api_bench = ApisBench.where(bench_id: self.id, api_id: api_id).last
    benches_game = BenchesGame.where(game_id: game_id, bench_id: self.id).last
      parsed.each_with_index do |parse, i|
          # threads << Thread.new {
          input = Input.new(variation_id: variation_id, game_id: game_id, bench_id: self.id, benches_game_id: benches_game.id,
                        type_id: type_id, fps: parse[0], frametime: parse[1].to_f / 1000, cpu: parse[2], gpu: parse[3],
                        color: color, pos: parse[10], apis_bench_id: api_bench.id, api_id: api_id)
          inputs.push(input)
          if inputs.count > 1000
            Input.import inputs
            inputs = []
          end
          # }
          # if threads.count > 3
            # threads.each {|thr| thr.join}
            # threads = []
          # end
          ActionCable.server.broadcast 'web_notifications_channel', (((i + 0.0) / length) * 100).to_i if i % 50 == 0
      end
    Input.import inputs
    self.refresh_json(benches_game)
    # self.refresh_json_api
    ActionCable.server.broadcast 'web_notifications_channel', 100
  end

  def parse_upload_ocat(game_id, variation_id, type_id, bench_id, color, api_id)
    require 'csv'
    parsed = CSV.parse(upload.attachment.download)
    length = parsed.count
    count = 0
    frametime = 0
    time_col = 0
    last_frame = 2
    parsed.each_with_index do |parse, i|
      if parsed[0][i] == "MsBetweenPresents"
        frametime = i
      end
      if parsed[0][i] == "TimeInSeconds"
        time_col = i
      end
    end
      parsed.each_with_index do |parse, i|
        unless i == 0
          if parsed[last_frame][time_col].to_f + 0.096 <= parse[time_col].to_f
            last_frame = i
            Input.create!(variation_id: variation_id, game_id: game_id, bench_id: self.id, benches_game_id: BenchesGame.where(game_id: game_id, bench_id: self.id).last.id,
                          type_id: type_id, fps: 1000 / parse[frametime].to_f, frametime: parse[frametime].to_d,
                          color: color, pos: count, apis_bench_id: ApisBench.where(bench_id: self.id, api_id: api_id).last.id, api_id: api_id)
            count += 1
          end

        end
        ActionCable.server.broadcast 'web_notifications_channel', (((i + 0.0) / length) * 100).to_i if i % 50 == 0
    end
    benches_game = BenchesGame.where(game_id: game_id, bench_id: self.id).last
    self.refresh_json
    # self.refresh_json_api
    ActionCable.server.broadcast 'web_notifications_channel', 100
  end
  
  def refresh_json(benches_game)
    Input.where(fps: 0).delete_all
    onepercent = {}
    percentile97 = {}
    self.inputs.where(fps: nil).delete_all
      fps_chart = benches_game.types.order(:name).map { |type|
        {name: type.name, data: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).where(
        id: type.inputs.map {|input| input if input.pos.to_i % 100 == 0 }.compact.pluck(:id)).group(:pos).average(:fps),
        color: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).last.color}}.chart_json
      frametime_chart = benches_game.types.order(:name).map { |type| {name: type.name, data: type.inputs.where(
        benches_game_id: benches_game.id).where(bench_id: self.id).where(id: type.inputs.map {
        |input| input if input.pos.to_i % 100 == 0 }.compact.pluck(:id)).group(:pos).average(:frametime),
        color: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).last.color}}.chart_json
      full_fps_chart = benches_game.types.order(:name).map { |type| {name: type.name, data: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).group(:pos).average(:fps), color: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).last.color}}.chart_json
      full_frametime_chart = benches_game.types.order(:name).map { |type| {name: type.name, data: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).group(:pos).average(:frametime), color: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).last.color}}.chart_json
      gpu_chart = benches_game.types.order(:name).map { |type| {name: type.name, data: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).group(:pos).average(:gpu), color: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).last.color}}.chart_json
      cpu_chart = benches_game.types.order(:name).map { |type| {name: type.name, data: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).group(:pos).average(:cpu), color: type.inputs.where(benches_game_id: benches_game.id).where(bench_id: self.id).last.color}}.chart_json
      onepercent = {}
      benches_game.types.order(name: :asc).each do |type|
        typeInputs = type.inputs.where(game_id: benches_game.game_id, bench_id: benches_game.bench_id)
        pluck = typeInputs.where(id: typeInputs.order(fps: :asc).limit(typeInputs.count * 0.1)).pluck(:id)
        onepercent.store(type.name, typeInputs.where(id: pluck).average(:fps))
        percentile97.store(type.name, Bench.percentile(typeInputs.pluck(:fps).sort, 0.97))
      bar_chart = [
              {
                name: '1% Min',
                data: onepercent
              },
              {
                name: 'Avg',
                data: benches_game.inputs.joins(:type).group('types.name').order('types.name ASC').average(:fps),
              },
              {
                name: '97th percentile',
                data: percentile97
              },


              # {
              #   name: '1% Min',
              #   data: benches_game.inputs.where(bench_id: self.id).where(id: benches_game.inputs.order(fps: :asc).first(benches_game.inputs.count * 0.1).pluck(:id)).joins(:type).group('types.name').average(:fps),
              # },
              # {
              #   name: '0.1% Min',
              #   data: benches_game.inputs.where(bench_id: self.id).where(id: benches_game.inputs.order(fps: :asc).first(benches_game.inputs.count * 0.01).pluck(:id)).joins(:type).group('types.name').average(:fps),
              # },

            ]
      avgcpu_chart = self.inputs.where(bench: self).joins(:type).group('types.name').order('types.name ASC').average(:cpu).chart_json
      benches_game.update(fps: fps_chart, frametime: frametime_chart, full_fps: full_fps_chart,
                          full_frametime: full_frametime_chart, bar: bar_chart.chart_json, gpu: gpu_chart, avgcpu: avgcpu_chart,
                          cpu: cpu_chart, min: benches_game.inputs.minimum(:fps), max: benches_game.inputs.maximum(:fps))
    end
    if self.games.count > 1
      totalbar_chart = self.types.order(name: :asc).map {|type| {name: type.name, data: type.inputs.joins(:type).where(bench: self).group('types.name').average(:fps)}}
      totalcpu_chart = self.inputs.where(bench: self).joins(:type).group('types.name').order('types.name ASC').average(:cpu).chart_json
      self.update(totalbar: totalbar_chart.chart_json, totalcpu: totalcpu_chart)
    end
  end
  
  def refresh_json_api
    Input.where(fps: 0).delete_all
    if self.apis.count > 1
    self.apis.each do |api|
      apis_bench = ApisBench.where(api_id: api.id, bench_id: self.id).last
      fps_chart = apis_bench.types.order(:name).map { |type| {name: type.name, data: type.inputs.where(apis_bench_id: apis_bench.id).where(bench_id: self.id).where(id: type.inputs.map {|input| input if input.id % 2 == 0 }.compact.pluck(:id)).group(:pos).average(:fps), color: type.inputs.where(apis_bench_id: apis_bench.id).where(bench_id: self.id).last.color}}.chart_json
      frametime_chart = apis_bench.types.order(:name).map { |type| {name: type.name, data: type.inputs.where(apis_bench_id: apis_bench.id).where(bench_id: self.id).where(id: type.inputs.map {|input| input if input.id % 2 == 0 }.compact.pluck(:id)).group(:pos).average(:frametime), color: type.inputs.where(apis_bench_id: apis_bench.id).where(bench_id: self.id).last.color}}.chart_json
      full_fps_chart = apis_bench.types.order(:name).map { |type| {name: type.name, data: type.inputs.where(apis_bench_id: apis_bench.id).where(bench_id: self.id).group(:pos).average(:fps), color: type.inputs.where(apis_bench_id: apis_bench.id).where(bench_id: self.id).last.color}}.chart_json
      full_frametime_chart = apis_bench.types.order(:name).map { |type| {name: type.name, data: type.inputs.where(apis_bench_id: apis_bench.id).where(bench_id: self.id).group(:pos).average(:frametime), color: type.inputs.where(apis_bench_id: apis_bench.id).where(bench_id: self.id).last.color}}.chart_json
      onepercent = {}
      percentile97 = {}
      apis_bench.types.each do |type|
        typeInputs = type.inputs.where(bench_id: self.id)
        pluck = typeInputs.where(id: typeInputs.order(fps: :asc).limit(typeInputs.count * 0.1)).pluck(:id)
        onepercent.store(type.name, typeInputs.where(id: pluck).average(:fps))
        percentile97.store(type.name, Bench.percentile(typeInputs.pluck(:fps).sort, 0.97))
      end
      bar_chart = [
              {
                name: '1% Min',
                data: onepercent
              },
              {
                name: 'Avg',
                data: apis_bench.inputs.where(bench_id: self.id).joins(:type).group('types.name').order('types.name ASC').average(:fps),
              },
              {
                name: '97th percentile',
                data: percentile97
              }
            ]
      apis_bench.update(fps: fps_chart, frametime: frametime_chart, full_fps: full_fps_chart, full_frametime: full_frametime_chart, bar: bar_chart)
    end
    if self.games.count > 1
      apis_bench = ApisBench.where(api_id: api.id, bench_id: self.id).last
      totalbar_chart = [
              # {
              #   name: 'Max',
              #   data: self.inputs.where(bench_id: self.id).joins(:type).order('types.name').group('types.name').maximum(:fps),
              # },
              {
                name: 'Avg',
                data: self.inputs.where(bench_id: self.id).joins(:type).group('types.name').order('types.name ASC').average(:fps)
              },
              # {
              #   name: '1% Min',
              #   data: onepercent
              # },
              # {
              #   name: '1% Min',
              #   data: benches_game.inputs.where(bench_id: self.id).where(id: benches_game.inputs.order(fps: :asc).first(Input.count * 0.1).pluck(:id)).joins(:type).group('types.name').average(:fps),
              # },
              # {
              #   name: '0.1% Min',
              #   data: benches_game.inputs.where(bench_id: self.id).where(id: benches_game.inputs.order(fps: :asc).first(Input.count * 0.01).pluck(:id)).joins(:type).group('types.name').average(:fps),
              # },
              # {
              #   name: 'Min',
              #   data: self.inputs.where(bench_id: self.id).joins(:type).group('types.name').minimum(:fps),
              # }
            ]
            self.update(totalbar: totalbar_chart)
      end
    end
  end
  
  def get_desc
    require 'open-uri'
    url = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id=" + self.youtubeid + "&key=" + ENV["YOUTUBE_KEY"]
    data = JSON.load(open(url))
    self.update(description: data["items"][0]["snippet"]["description"])
  end
  
end

