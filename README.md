# MaxAlertView

# show a title</br>
[MaxAlertView showAlertWithTitle:@"AlertView show Title"];

# show title & message</br>
[MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message"];

# show title & message , at the same time show a cancel button</br>
[MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" completion:^(BOOL cancelled) {
    NSLog(@"cancel");
}];

# show title & message , at the same time show a cancel button & confirm button</br>
[MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" otherTitle:@"confirm" completion:^(BOOL cancelled) {
    if (cancelled) {
          NSLog(@"cancel");
    }else {
          NSLog(@"confirm");
    }
}];

# show title & message , at the same time show a cancel button & confirm button , contentView</br>
[MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" otherTitle:@"confirm" contentView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wode_ydy"]] completion:^(BOOL cancelled) {</br>
    if (cancelled) {
          NSLog(@"cancel");
    }else {
          NSLog(@"confirm");
    }
}];

# show title & message , at the same time show a cancel block with OK</br>
[MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" completion:^(BOOL cancelled) {</br>
    if (cancelled) {
          NSLog(@"ok");
    }
}];
