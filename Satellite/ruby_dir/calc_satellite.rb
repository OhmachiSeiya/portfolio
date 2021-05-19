# コマンド例： ruby calc_satellite.rb 1 7078 0 0 0
# または mruby -b calc_satellite.mrb 1 7078 0 0 0

command_num = ARGV[0].to_i
a = ARGV[1].to_f
e = ARGV[2].to_f
theta = ARGV[3].to_f
i = ARGV[4].to_f
o = ARGV[5].to_f
w = ARGV[6].to_f

class CalcSatellite
  # 参考文献： 「人工衛星をつくる（宮崎康行 著）」
  #  a … 楕円軌道の長半径
  #  e … 楕円の離心率（地球が楕円の中心からどれだけの割合ずれているかを表す）
  #  i … 軌道傾斜角（楕円軌道面と赤道面がなす角度）
  #  o … 昇交点赤経
  #  w … 近地点引数
  #  theta … 真近点角

  def initialize()
    @m_e = 3.986 * 1014  # 地球の重力定数（3.986*1014 [m3/s2]）
    @r_e = 6378          # 地球の半径(6378 [km])
    @j_2 = 0.001082628   # 地球の扁平性を表す定数(0.001082628)
  end

  def velocity(a,e,theta)
    v = Math.sqrt(
      @m_e * (1 + e**2 + 2*e*Math.cos(theta)) / 
      a * (1 - e**2)
    )
    return v
  end

  def periodic_time(a)
    t = 2*Math::PI*(a**1.5 / Math.sqrt(@m_e))
    return t
  end

  def sso_check(a, e, i, tolerance=10**-5)
    # 太陽同期軌道（sun_synchronous_orbit）となる条件式の正誤を判定する
    # 太陽同期軌道 … iとaを調整して同じ経度に戻るようにした時の軌道
    # tolerance: 許容誤差

    comparison = 1.99 * 10**(-7)
    res = -(
      (3*@j_2*@r_e**2) / (2*a**2*(1-e**2)**2) *
      Math.sqrt(@m_e / a**3) *
      Math.cos(i)
    )
    diff = (res - comparison).abs
    cond = diff < tolerance
    
    if cond
      return "OK"
    else
      return "iとaを修正してください。"
    end
  end
end

begin 
  cs = CalcSatellite.new()
 
  if command_num == 1
    v = cs.velocity(a,e,theta)
    puts "速さは#{v}"
  elsif command_num == 2
    v = cs.velocity(a,e,theta)
    t = cs.periodic_time(a)
    puts "速さは#{v}"
    puts "周期は#{t}"
  elsif command_num == 3
    c = cs.sso_check(a,e,i)
    puts c
  elsif command_num == 4
    c_2 = cs.sso_check(a,e,i,tolerance=10**-9)
    puts c_2
  else
    puts "コマンドは1~4です。"
  end
rescue => e
  puts "エラーが発生しました。"
  puts e.message
ensure 
  puts "コマンド処理を終了します。"
end
