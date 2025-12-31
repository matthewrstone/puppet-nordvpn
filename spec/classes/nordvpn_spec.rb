# frozen_string_literal: true

require 'spec_helper'

describe 'nordvpn' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          token: 'test_token_12345',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it {
        is_expected.to contain_apt__source('nordvpn').with(
          location: 'https://repo.nordvpn.com/deb/nordvpn/debian',
          release: 'stable',
          repos: 'main',
          key: {
            'id' => 'BC5480EFEC5C081CE5BCFBE26B219E535C964CA1',
            'source' => 'https://repo.nordvpn.com/gpg/nordvpn_public.asc',
          },
        ).that_comes_before('Package[nordvpn]')
      }

      it {
        is_expected.to contain_package('nordvpn').with(
          ensure: 'installed',
        )
      }

      it {
        is_expected.to contain_service('nordvpnd').with(
          ensure: 'running',
          enable: true,
        ).that_requires('Package[nordvpn]')
      }

      it {
        is_expected.to contain_exec('nordvpn-login').with(
          command: '/usr/bin/nordvpn login --token test_token_12345',
          unless: '/usr/bin/nordvpn account',
        ).that_requires('Service[nordvpnd]')
      }

      it {
        is_expected.to contain_exec('nordvpn-connect').with(
          command: '/usr/bin/nordvpn connect',
          unless: '/usr/bin/nordvpn status | grep "Connected"',
        ).that_requires('Exec[nordvpn-login]')
      }
    end
  end
end
