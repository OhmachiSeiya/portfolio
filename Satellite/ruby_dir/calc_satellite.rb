# コマンド例： ruby calc_satellite.rb 1 7078 0 0 0
# または mruby -b calc_satellite.mrb 1 7078 0 0 0
require 'numo/narray'

command_num = ARGV[0].to_i
if command_num == 1
  a, e, theta, i, o, w = ARGV[1].to_f, ARGV[2].to_f, ARGV[3].to_f, ARGV[4].to_f, ARGV[5].to_f, ARGV[6].to_f
elsif command_num == 2
  p_sat, l_tr, n_0, cn_req = ARGV[1].to_f, ARGV[2].to_f, ARGV[3].to_f, ARGV[4].to_f
  d, f = ARGV[5].to_f, ARGV[6].to_f
  t_a,t_f,t_e,l_frk = ARGV[7].to_f, ARGV[8].to_f, ARGV[9].to_f, ARGV[10].to_f
elsif command_num == 3
  m,b_s, y_air,f_air, y_sun,f_sun = ARGV[1].to_f, ARGV[2].to_f, ARGV[3].to_f, ARGV[4].to_f, ARGV[5].to_f, ARGV[6].to_f
end


module CalcSat
  # 参考文献： 「人工衛星をつくる（宮崎康行 著）」
  class Orbita
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

  class Communication
    # 通信
    # p_sat: 衛星からの電波の電力
    # l_tr: 衛星からの電波が地上に届くまでのロス
    # c_p: 搬送波電力
    # n_0: 雑音電力密度
    def initialize()
      @c = 2.9979 * 10**6 # 電波の速さ 2.9979 * 10**6 [km/sec]
    end

    def line_establised?(p_sat, l_tr, n_0, cn_req)
      # 通信回線が成立するか判定
      c_p = p_sat - l_tr
      cn = c_p / n_0
      cond = cn - cn_req > 3
      return cond
    end

    def fspl(d, f)
      #自由空間伝搬損失 Free Space Path Loss
      #電波が地上に届くまでに弱まってしまう割合

      l_d = (@c / 4*Math::PI*f*d)**2
      return l_d
    end

    def system_noise_temp(t_a,t_f,t_e,l_frk)
      t_s = (t_a/l_frk) + (1 - (1/l_frk))*t_f + t_e
      return t_s
    end
  end

  class Posture
    # 姿勢
    def torque(m,b_s, y_air,f_air, y_sun,f_sun)
      n_mag = m * b_s
      n_air = y_air * f_air
      n_sun = y_sun * f_sun
      dict = {"n_mag":n_mag, "n_air":n_air, "n_sun":n_sun}
      return dict
    end
  end

  class Kalman
    include Numo
  
    attr_accessor :ft0, :pt1, :qt0, :gt0, :xht1, :ht0, :rt0
  
    def predict(ut0)
      ut0 = 0 if not ut0
      @xht0 = @ft0.dot(@xht1) + ut0
      @pt0 = @ft0.dot(@pt1).dot(@ft0.transpose)+@gt0.dot(@qt0).dot(@gt0.transpose)
      [@xht0, @pt0]
    end
  
    def update(zt0)
      @xht1 = @xht0 + kt0.dot(et0(zt0))
      ktht = kt0.dot(@ht0)
      @pt1 = (Int32.eye(*ktht.shape) - ktht).dot(@pt0)
      [@xht1, @pt1]
    end
  
    def observe(zt0, ut0=nil)
      predict(ut0)
      update(zt0)
    end
  
    def et0(zt0)
      zt0 - @ht0.dot(@xht0)
    end
  
    def st0
      @rt0 + @ht0.dot(@pt0).dot(@ht0.transpose)
    end
  
    def kt0
      @pt0.dot(@ht0.transpose).dot(Matrix[*st0.to_a].inv.to_a)
    end
  end
end

begin 
  if command_num == 1
    orb = CalcSat::Orbita.new()
    v = orb.velocity(a,e,theta)
    t = orb.periodic_time(a)
    c_1 = orb.sso_check(a,e,i,tolerance=10**-9)
    puts "速さは#{v}"
    puts "周期は#{t}"
    puts c_1
  elsif command_num == 2
    com = CalcSat::Communication.new()
    if com.line_establised?
      fspl = com.fspl(d, f)
      snt = com.system_noise_temp(t_a,t_f,t_e,l_frk)
      puts "自由空間伝搬損失は#{fspl}"
      puts "システム雑音温度は#{snt}"
    else
      puts "通信回線が成立しません"
    end
  elsif command_num == 3
    pos = CalcSat::Posture.new()
    torque = pos.torque(m,b_s, y_air,f_air, y_sun,f_sun)
    puts torque
  else
    puts "1か2か3を入力してください"
  end
rescue => e
  puts "エラーが発生しました。"
  puts e.message
ensure 
  puts "コマンド処理を終了します。"
end
