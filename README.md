# MaxAlertView

# [MaxAlertView showAlertWithTitle:@"AlertView show Title"];

# [MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message"];

# [MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" completion:^(BOOL cancelled) {NSLog(@"cancel");}];

# [MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" otherTitle:@"confirm" completion:^(BOOL cancelled) {if (cancelled) {NSLog(@"cancel");}else {NSLog(@"confirm");}}];

# [MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" otherTitle:@"confirm" contentView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wode_ydy"]] completion:^(BOOL cancelled) {if (cancelled) {NSLog(@"cancel");}else {NSLog(@"confirm");}}];

# [MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" completion:^(BOOL cancelled) {if (cancelled) {NSLog(@"ok");}}];
