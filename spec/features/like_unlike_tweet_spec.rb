require "rails_helper"

RSpec.feature "like/unlike tweets",type: :feature do

  let!(:user){create(:user)}

  before do
    visit "/users/sign_in"
    fill_in 'Email',with: user.email
    fill_in 'Password',with: user.password
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'
  end

  before do
    visit('/')
    expect(page).to have_content 'Home'
    fill_in 'tweet_body',with:"Test tweet"
    click_button 'Tweet'
  end
  # let!(:tweet){create(:tweet)}
  # let!(:retweet){create(:retweet_type)}
  # let!(:reply){create(:reply_type)}

  scenario "like tweet" do
    expect(page).to have_content "Test tweet"
    expect { find(:css, '.fa-heart').click }.to change{Tweet.last.likes.count}.by(1)

  end

  scenario "unlike tweet" do
    expect(page).to have_content "Test tweet"

    binding.pry

    find(:css, '.fa-heart').click
    binding.pry
    expect { find(:css, '.fa-heart').click }.to change{Tweet.last.likes.count}.by(-1)

    binding.pry

  end


end