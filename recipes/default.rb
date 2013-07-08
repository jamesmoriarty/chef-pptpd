package 'pptpd'

service 'pptpd' do
  supports :start => true, :restart => true
  action [ :enable, :start ]
end

directory '/etc/ppp/' do
  mode '755'
end

cookbook_file '/etc/pptpd.conf' do
  source 'pptpd.conf'
  notifies :restart, resources(:service => 'pptpd')
end

cookbook_file '/etc/ppp/pptp-options' do
  source 'pptp-options'
  notifies :restart, resources(:service => 'pptpd')
end

template '/etc/ppp/chap-secrets' do
  source 'chap-secrets.erb'
  owner 'root'
  group 'root'
  mode 0755
  notifies :restart, resources(:service => 'pptpd')
end

execute 'enable masquerade' do
  command 'iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE'
  not_if  'iptables --list-rules | grep eth0 | grep MASQUERADE'
end

execute 'enable ip4 forwarding' do
  command "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf && sysctl -p"
  not_if  '[ $(cat /proc/sys/net/ipv4/ip_forward) -eq 0 ]'
end
