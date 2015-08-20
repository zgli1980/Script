echo 
echo "http proxy status"
networksetup -getwebproxy Wi-Fi
echo 
echo "https proxy status"
networksetup -getsecurewebproxy Wi-Fi
echo
echo "socks proxy status"
networksetup -getsocksfirewallproxy Wi-Fi
echo
