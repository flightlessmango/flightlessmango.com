class Bench < ApplicationRecord
  include Rails.application.routes.url_helpers
  extend FriendlyId
  friendly_id :youtubeid, use: :slugged

  has_and_belongs_to_many :games, through: :inputs
  has_and_belongs_to_many :apis, through: :inputs
  has_many :inputs
  has_many :benches_games
  has_many :types
  has_many :variations
  has_one_attached :upload
  has_one_attached :stats
  
  COLORS    =  ["#3398dc", "#6639b6", "#e64b3b", "#72c02c", "#ebc71d", "#ed4a82", "#b09980", "#22e3be", "#fe541e", "#00BB27", "#4000FF"]
  COLORSRGB =  ["rgba(51,152,220,1)", "rgba(102,57,182,1)", "rgba(230,75,59,1)", "rgba(114,192,44,1)", "rgba(235,199,29,1)"]
  TWENTY    =  [ '#e6194b', '#3cb44b', '#4363d8', '#911eb4', '#f58231', '#E899DC', '#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324', '#fffac8',
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
    benches_game = BenchesGame.where(game_id: game_id, bench_id: self.id).last
    api_bench = ApisBench.where(bench_id: self.id, api_id: api_id).last.id
    inputs = [
      parsed.each_with_index do |parse, i|
        Input.new(variation_id: variation_id, game_id: game_id, bench_id: self.id, benches_game_id: benches_game.id,
                      type_id: type_id, fps: parse[1], frametime: (1000 / parse[1].to_f).round(2),
                      cpu: parse[2].to_f, gpu: parse[2].to_i, color: color, pos: parse[3], apis_bench_id: api_bench, api_id: api_id)
        ActionCable.server.broadcast 'web_notifications_channel', (((i + 0.0) / length) * 100).to_i if i % 100 == 0
      end
    ]
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
  
  def parse_upload_mango(benches_game_id, variation_id, color, port)
    require 'csv'
    puts benches_game_id
    Variation.find(variation_id).update_attribute(:color, color)
    @benches_game = BenchesGame.find(benches_game_id)
    self.update_attribute(:compare_to, self.benches_games.first.id) if self.compare_to.nil?
    parsed = CSV.parse(upload.attachment.download)
    count = 0
    length = parsed.count
    inputs = []
    parsed.each_with_index do |parse, i|
        input = Input.new(variation_id: variation_id, bench_id: self.id, benches_game_id: benches_game_id,
                      fps: parse[0], frametime: parse[1].to_f / 1000, cpu: parse[2], gpu: parse[3], color: color, pos: parse[10])
        inputs.push(input)
        puts inputs.count
        ActionCable.server.broadcast 'web_notifications_channel', (((i + 0.0) / length) * 100).to_i if i % 50 == 0
    end
    Input.import inputs
    puts "imported"
    refresh_json(@benches_game, port)
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
  
  def refresh_json(benches_game, port)
    Input.where(fps: 0).delete_all
    self.inputs.where(fps: nil).delete_all
    full_frametime_chart = {}
    full_fps_chart = {}
    fps_chart = {}
    frametime_chart = {}
    bar_chart = {}
    totalbar_chart = {}
    gpu_chart = {}
    cpu_chart = {}

    require "json"
    require "net/http"
    require "uri"
    http_protocol = ""
    if Rails.env.development?
      http_protocol = "http"
    else
      http_protocol = "https"
    end
    url = url_for(action: 'stats', controller: 'benches', only_path: false, protocol: http_protocol, id: self.slug)
    kit = IMGKit.new(url.to_s).to_file(self.slug + ".png")
    `convert #{self.slug + ".png"} -crop 600x315+47 +repage #{self.slug + ".png"}`
    ["fps", "frametime"].each do |graph_type|
      url = url_for(action: 'show', controller: 'benches_games', only_path: false, protocol: http_protocol, id: benches_game.id, :format => :json, :graph_type => graph_type, :size => "full", port: port)
      response = Net::HTTP.get(URI(url))
      if graph_type == "fps"
        full_fps_chart = response
      end
      if graph_type == "frametime"
        full_frametime_chart = response
      end
    end

    ["fps", "frametime", "bar", "cpu", "gpu"].each do |graph_type|
          url = url_for(action: 'show', controller: 'benches_games', only_path: false, protocol: http_protocol, id: benches_game.id, :format => :json, :graph_type => graph_type, :size => "mini", port: port)
          response = Net::HTTP.get(URI(url))
          if graph_type == "fps"
            fps_chart = response
          end
          if graph_type == "frametime"
            frametime_chart = response
          end
          if graph_type == "bar"
            bar_chart = response
          end
          if graph_type == "cpu"
            cpu_chart = response
          end
          if graph_type == "gpu"
            gpu_chart = response
          end
    end

    # avgcpu_chart = self.inputs.where(bench: self).joins(:type).group('types.name').order('types.name ASC').average(:cpu).chart_json
    benches_game.variations.each do |type|
      typeInputs = type.inputs
      pluck = typeInputs.where(id: type.inputs.order(fps: :asc).limit(type.inputs.count * 0.1).pluck(:id))
      onepercent = typeInputs.where(id: pluck).average(:fps).round(1)
      ninetyseven = Bench.percentile(typeInputs.pluck(:fps).sort, 0.97).round(1)
      avg = typeInputs.average(:fps).round(1)
      compared = ((avg / Variation.find(benches_game.compare_id).inputs.average(:fps).round(1)) * 100).round(2)
      type.update(onemin: onepercent, ninetyseventh: ninetyseven, avg: avg, compared: compared)
    end
    benches_game.update(full_fps: full_fps_chart, full_frametime: full_frametime_chart, frametime: frametime_chart, fps: fps_chart,
                        bar: bar_chart, min: benches_game.inputs.minimum(:fps), cpu: cpu_chart, gpu: gpu_chart,
                        max: benches_game.inputs.maximum(:fps))
    self.stats.attach(io: File.open(self.slug + ".png"), filename: "stats.png")
    `rm #{self.slug + ".png"}`
    ActionCable.server.broadcast 'web_notifications_channel', "reload"
    return
  end

  def refresh_json_total
    require "net/http"
    require "uri"
    http_protocol = ""
    if Rails.env.development?
      http_protocol = "http"
    else
      http_protocol = "https"
    end
    url = url_for(action: 'stats', controller: 'benches', only_path: false, protocol: http_protocol, id: self.slug)
    kit = IMGKit.new(url.to_s).to_file(self.slug + ".png")
    url = url_for(action: 'show', controller: 'benches_games', only_path: false, protocol: http_protocol, id: self.benches_games.last.id, :format => :json, :graph_type => "totalbar")
    uri = URI(url)
    response = Net::HTTP.get(uri)
    totalbar_chart = response
    # totalcpu_chart = self.inputs.where(bench: self).joins(:type).group('types.name').order('types.name ASC').average(:cpu).chart_json

    self.variations.pluck(:name).uniq do |type_name|
      typeInputs = self.inputs.where(variation_id: self.variations.where(name: type_name).pluck(:id))
      pluck = typeInputs.where(id: typeInputs.order(fps: :asc).limit(typeInputs.count * 0.1).pluck(:id))
      onepercent = typeInputs.where(id: pluck).average(:fps).round(1)
      ninetyseven = Bench.percentile(typeInputs.pluck(:fps).sort, 0.97).round(1)
      avg = typeInputs.average(:fps).round(1)
      compared_inputs = Input.where(variation_id: Variation.where(name: Variation.find(self.compare_to).name).pluck(:id))
      compared = ((avg / compared_inputs.average(:fps).round(1)) * 100).round(2)
      self.update(onemin: onepercent, ninetyseventh: ninetyseven, avg: avg, compared: compared)
    end
    self.update(totalbar: totalbar_chart)
    self.stats.attach(io: File.open(self.slug + ".png"), filename: "stats.png")
    `rm #{self.slug + ".png"}`
    return
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

  def type_avg
    array = []
    self.types.order(name: :desc).each do |type|
      array.push(type.inputs.where(bench: self).average(:fps).to_i)
    end
    return array
  end

  def refresh_all(port)
    self.benches_games.each do |game|
        self.refresh_json(game, port)
    end
    self.refresh_json_total if self.games.count > 1
  end
  
  def type_colors
    array = []
    self.types.order(name: :asc).each do |type|
      array.push(type.inputs.where(bench: self).last.color)
    end
    return array
  end

  def publish
    @benchmark = Bench.friendly.find(self.id)
    @benchmark.update(published: true)
    @benchmark.get_desc
  end
end

