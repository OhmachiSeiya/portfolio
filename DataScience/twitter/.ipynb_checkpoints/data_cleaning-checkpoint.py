import pandas as pd
import numpy as np
import os
import glob
import re
  
class CleanTW():
  """
  twitterアナリティクスで取得したデータを整理
  """
  
  def __init__(self):
    self.path = "./data_by_tweet"
    
  def convert_filename(self):
    """
    ファイル名を変換する
    """
    files = glob.glob(self.path + '/tweet_activity*')
    for f in files:
        os.rename(f, self.path + "/tw" + f[-25:-18] + ".csv")

  def load_data(self):
    """
    ./data_by_tweet直下のデータを連結してdataframeにする
    """
    files = glob.glob(self.path + '/tw_20*')
    tw = pd.DataFrame()
    for f in files:
      tw = pd.concat([tw,pd.read_csv(f)])
    self.tw = tw
    
  def clean_table(self):
    tw = self.tw
    tw['時間'] = pd.to_datetime(tw['時間'])
    tw = tw.sort_values('時間', ascending=False)
    tw = tw.reset_index(drop=True)
    # '-'を削除
    tw = tw.replace({'-': np.nan,'NaN': np.nan, 'nan': np.nan})
    tw = tw.dropna(how='all',axis=1)
    # 重複しているツイートをツイートIDについて一意に変更
    tw = tw.loc[~(tw.duplicated(subset=['ツイートID']))]
    tw = tw.reset_index(drop=True)
    tw = tw.fillna(0)
    # 全てが0の列を確認
    all_0_cols = []
    for col in tw.columns:
      if (tw[col] == 0).all() == True:
        all_0_cols.append(col)
    tw = tw.drop(columns=all_0_cols)
    tw = tw.sort_values('時間', ascending=False)
    tw = tw.reset_index(drop=True)
    self.tw = tw

  def _format_text(self,text):
    text=re.sub(r'https?://[\w/:%#\$&\?\(\)~\.=\+\-…]+', "", text)
    text=re.sub(r'[!-~]', "", text)#半角記号,数字,英字
    text=re.sub(r'[︰-＠]', "", text)#全角記号
    text=re.sub('\n', " ", text)#改行文字
    return text

  def add_columns(self):
    tw = self.tw
    tw['ツイート本文_x'] = tw['ツイート本文'].apply(lambda s: self._format_text(s))
    tw['文字数'] = tw['ツイート本文_x'].str.len()
    tw['media_exist'] = tw['ツイート本文'].str.contains('t.co')
    tw.loc[tw['media_exist'] == True, 'media_exist'] = 1
    tw.loc[tw['media_exist'] == False, 'media_exist'] = 0
    tw['reply_flg'] = tw['ツイート本文'].str.contains('@')
    tw.loc[tw['reply_flg'] == True, 'reply_flg'] = 1
    tw.loc[tw['reply_flg'] == False, 'reply_flg'] = 0

    tw['時間'] = pd.to_datetime(tw['時間'])
    tw['YMD'] = tw['時間'].dt.strftime('%Y%m%d')
    tw['YEAR'] = tw['時間'].dt.year
    tw['MONTH'] = tw['時間'].dt.month
    tw['DAY'] = tw['時間'].dt.day
    tw['TIME'] = tw['時間'].dt.hour
    tw['WEEKDAY'] = tw['時間'].dt.weekday
    tw['WEEK'] = tw['時間'].dt.isocalendar().week

    tw = tw.drop(columns='ツイートの固定リンク')
    self.tw = tw

  def sort_for_understand(self):
    tw = self.tw
    tw = tw[[
       'ツイート本文','ツイート本文_x', '時間', 'いいね','リツイート', 'インプレッション', 'エンゲージメント', 'エンゲージメント率',
       '返信', 'ユーザープロフィールクリック', 'URLクリック数', 'ハッシュタグクリック', '詳細クリック',
       'フォローしている', 'メディアの再生数', 'メディアのエンゲージメント数', '文字数', 
       'media_exist', 'reply_flg', 'YMD', 'YEAR', 'MONTH', 'DAY', 'TIME', 'WEEKDAY','WEEK'
    ]]
    self.tw = tw
    
  def run_all(self):
    self.convert_filename()
    self.load_data()
    self.clean_table()
    self.add_columns()
    self.sort_for_understand()
    return self.tw
    
    

