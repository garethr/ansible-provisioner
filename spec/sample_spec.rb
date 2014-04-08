require 'spec_helper'

describe package('curl') do
  it { should be_installed }
end
