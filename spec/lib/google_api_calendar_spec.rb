require_relative '../../lib/google_api_calendar_v3'

describe "GoogleCalendarテスト" do
  gac = GoogleCalendar.new
  it '認証通って予定がない場合「今日の予定はないよ」と「明日の予定はないよ」となる' do
    expect(gac.get_schedule).to eq "今日の予定はないよ\n明日の予定はないよ\n"
  end

  it '予定がない場合引数[今日]は「今日の予定はないよ」となること' do
    expect(gac.make_schedule_message('今日')).to eq "今日の予定はないよ\n"
  end

  it '予定がない場合引数[明日]は「明日の予定はないよ」となること' do
    expect(gac.make_schedule_message('明日')).to eq "明日の予定はないよ\n"
  end

  it '予定がある場合はログを見て確認' do

  end

end