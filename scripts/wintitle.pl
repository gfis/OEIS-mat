use strict;
use warnings;
use Win32::API;

# Define the Windows API functions
my $GetForegroundWindow = Win32::API->new('user32', 'GetForegroundWindow', [], 'N');
my $GetWindowText       = Win32::API->new('user32', 'GetWindowText', ['N', 'P', 'I'], 'I');

# Get the handle
my $hwnd = $GetForegroundWindow->Call();

if ($hwnd) {
    # Prepare a buffer for the title (256 characters)
    my $buffer = " " x 256;
    my $length = $GetWindowText->Call($hwnd, $buffer, 256);
    
    # Trim the buffer to the actual length returned
    my $title = substr($buffer, 0, $length);
    print "Active Window Title: $title\n";
}