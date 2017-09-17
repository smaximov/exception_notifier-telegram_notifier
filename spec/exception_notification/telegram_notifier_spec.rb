# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExceptionNotification::TelegramNotifier do
  it 'has a version number' do
    expect(ExceptionNotification::TelegramNotifier::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
