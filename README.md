# MaxAlertView

//show a title
[MaxAlertView showAlertWithTitle:@"AlertView show Title"];

//show title & message
[MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message"];

//show title & message , at the same time show a cancel button
[MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" completion:^(BOOL cancelled) {
    NSLog(@"cancel");
}];

//show title & message , at the same time show a cancel button & confirm button
[MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" otherTitle:@"confirm" completion:^(BOOL cancelled) {
    if (cancelled) {
          NSLog(@"cancel");
    }else {
          NSLog(@"confirm");
    }
}];

//show title & message , at the same time show a cancel button & confirm button , contentView
[MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" otherTitle:@"confirm" contentView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wode_ydy"]] completion:^(BOOL cancelled) {
    if (cancelled) {
          NSLog(@"cancel");
    }else {
          NSLog(@"confirm");
    }
}];

//show title & message , at the same time show a cancel block with OK
[MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" completion:^(BOOL cancelled) {
    if (cancelled) {
          NSLog(@"ok");
    }
}];
