# コマンド例： ruby calc_satellite.rb 1 7078 0 0 0
# または mruby -b calc_satellite.mrb 1 7078 0 0 0
require 'numo/narray'
require './calc_satellite'

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
