//
//  FirstViewController.m
//  RemoteUIClient
//
//  Created by Oriol Ferrer Mesià on 11/05/14.
//  Copyright (c) 2014 Oriol Ferrer Mesià. All rights reserved.
//

#import "FirstViewController.h"

FirstViewController * paramsController;



void clientCallback(RemoteUIClientCallBackArg a){

	NSString * remoteIP = [NSString stringWithFormat:@"%s", a.host.c_str()];

	FirstViewController * me = paramsController;

	switch (a.action) {

		case SERVER_CONNECTED:{
			//[me showNotificationWithTitle:@"Connected to Server" description:remoteIP ID:@"ConnectedToServer" priority:-1];
		}break;

		case SERVER_DELETED_PRESET:{
			//[me showNotificationWithTitle:@"Server Deleted Preset OK" description:[NSString stringWithFormat:@"%@ deleted preset named '%s'", remoteIP, a.msg.c_str()] ID:@"ServerDeletedPreset" priority:1];
		}break;

		case SERVER_SAVED_PRESET:{
			//[me showNotificationWithTitle:@"Server Saved Preset OK" description:[NSString stringWithFormat:@"%@ saved preset named '%s'", remoteIP, a.msg.c_str()] ID:@"ServerSavedPreset" priority:1];
		}break;

		case SERVER_DID_SET_PRESET:{
			//[me hideAllWarnings];
			//[me showNotificationWithTitle:@"Server Did Set Preset OK" description:[NSString stringWithFormat:@"%@ did set preset named '%s'", remoteIP, a.msg.c_str()] ID:@"ServerDidSetPreset" priority:-1];
		}break;

		case SERVER_SAVED_GROUP_PRESET:{
			//[me showNotificationWithTitle:@"Server Saved Group Preset OK" description:[NSString stringWithFormat:@"%@ saved group preset named '%s'", remoteIP, a.msg.c_str()] ID:@"ServerSavedPreset" priority:1];
		}break;

		case SERVER_DID_SET_GROUP_PRESET:{
			//[me hideAllWarnings];
			//[me showNotificationWithTitle:@"Server Did Set Group Preset OK" description:[NSString stringWithFormat:@"%@ did set group preset named '%s'", remoteIP, a.msg.c_str()] ID:@"ServerDidSetPreset" priority:-1];
		}break;

		case SERVER_DELETED_GROUP_PRESET:{
			//[me showNotificationWithTitle:@"Server Deleted Group Preset OK" description:[NSString stringWithFormat:@"%@ deleted group preset named '%s'", remoteIP, a.msg.c_str()] ID:@"ServerDeletedPreset" priority:1];
		}break;

		case SERVER_SENT_FULL_PARAMS_UPDATE:
			//NSLog(@"## Callback: PARAMS_UPDATED");
			if(me->needFullParamsUpdate){ //a bit ugly here...
				[me fullParamsUpdate];
				me->needFullParamsUpdate = NO;
			}
			[me partialParamsUpdate];
			//[me updateGroupPopup];

			break;

		case SERVER_PRESETS_LIST_UPDATED:{
//			//NSLog(@"## Callback: PRESETS_UPDATED");
//			vector<string> presetsList = [me getClient]->getPresetsList();
//			if ( presetsList.size() > 0 ){
//				[me updatePresetsPopup];
//				[me updateGroupPresetMenus];
//			}
//			for(int i = 0; i < a.paramList.size(); i++){ //notify the missing params
//				ParamUI* t = me->widgets[ a.paramList[i] ];
//				[t flashWarning:[NSNumber numberWithInt:NUM_FLASH_WARNING]];
//			}
		}break;

		case SERVER_DISCONNECTED:{
			//NSLog(@"## Callback: SERVER_DISCONNECTED");
			[me connect];
			me->client->disconnect();
//			[me showNotificationWithTitle:@"Server Exited, Disconnected!" description:remoteIP ID:@"ServerDisconnected" priority:-1];
//			[me updateGroupPopup];
//			[me updatePresetsPopup];
//			[me updateGroupPresetMenus];
		}break;

		case SERVER_CONFIRMED_SAVE:{
			NSString * s = [NSString stringWithFormat:@"%@ - Default XML now holds the current param values", remoteIP];
//			[me showNotificationWithTitle:@"Server Saved OK" description:s ID:@"CurrentParamsSavedToDefaultXML" priority:1];
		}break;

		case SERVER_DID_RESET_TO_XML:{
			NSString * s = [NSString stringWithFormat:@"%@ - Params are reset to Server-Launch XML values", remoteIP];
//			[me showNotificationWithTitle:@"Server Did Reset To XML OK" description:s ID:@"ServerDidResetToXML" priority:0];
		}break;

		case SERVER_DID_RESET_TO_DEFAULTS:{
			NSString * s = [NSString stringWithFormat:@"%@ - Params are reset to its Share-Time values (Source Code Defaults)", remoteIP];
//			[me showNotificationWithTitle:@"Server Did Reset To Default OK" description:s ID:@"ServerDidResetToDefault" priority:0];
		}break;

		case SERVER_REPORTS_MISSING_PARAMS_IN_PRESET:{
			//printf("SERVER_REPORTS_MISSING_PARAMS_IN_PRESET\n");
//			for(int i = 0; i < a.paramList.size(); i++){
//				ParamUI* t = me->widgets[ a.paramList[i] ];
//				[t flashWarning:[NSNumber numberWithInt:NUM_FLASH_WARNING]];
//			}
		}

		case NEIGHBORS_UPDATED:{
//			[me updateNeighbors];
		}break;

		case SERVER_SENT_LOG_LINE:{
//			NSString * date = [[NSDate date] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil];
//			NSString * logLine = [NSString stringWithFormat:@"%@ >> %s\n", date,  a.msg.c_str() ];
//			[logs performSelectorOnMainThread:@selector(appendToServerLog:) withObject:logLine
//								waitUntilDone:NO];
		}break;

		case NEIGHBOR_JUST_LAUNCHED_SERVER:
//			[me autoConnectToNeighbor:a.host port:a.port];
			break;
		default:
			break;
	}

	if( a.action != SERVER_DISCONNECTED ){ //server disconnection is logged from connect button press
//		[logs log:a];
	}
}

#pragma mark -

@implementation FirstViewController


- (void)viewDidLoad{

	NSLog(@"viewDidLoad");
    [super viewDidLoad];
	paramsController = self;
	connected = NO;


	paramViews = [[NSMutableArray alloc] initWithCapacity:50];

	//	for(int i = 0; i < 50; i++){
	//		//UIView* paramview = [[[NSBundle mainBundle] loadNibNamed:@"ParamUI_ipad" owner:self options:nil] firstObject];
	//		RemoteUIParam p;
	//		NSString * name = [NSString stringWithFormat:@"param %d", i];
	//		ParamUI *paramView = [[ParamUI alloc] initWithParam:p name: [name UTF8String] ID:i];
	//		NSLog(@"%@", paramView);
	//		if (paramView){
	//			[paramViews addObject:paramView];
	//		}
	//	}

	client = new ofxRemoteUIClient();
	client->setCallback(clientCallback);
	client->setVerbose(false);

	bool OK = client->setup("127.0.0.1", 58477); //test
	//bool OK = client->setup("192.168.5.145", 13840); //test


	needFullParamsUpdate = YES; //before connect, always!
	client->connect();

	timer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_RATE target:self selector:@selector(update) userInfo:nil repeats:YES];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)cleanUpGUIParams{

//	for( map<string,ParamUI*>::iterator ii = widgets.begin(); ii != widgets.end(); ++ii ){
//		string key = (*ii).first;
//		ParamUI* t = widgets[key];
//		//[t release];
//	}
	widgets.clear();
	orderedKeys.clear();
	[paramViews removeAllObjects];

	//also remove the spacer bars. Dont ask me why, but dynamic array walking crashes! :?
	//that why this ghetto walk is here
//	NSArray * subviews = [listContainer subviews];
//	for( int i = (int)[subviews count]-1 ; i >= 0 ; i-- ){
//		[[subviews objectAtIndex:i] removeFromSuperview];
//		//[[subviews objectAtIndex:i] release];
//	}
//	[paramViews removeAllObjects];

}


-(void)fullParamsUpdate{

	[self cleanUpGUIParams];

	vector<string> paramList = client->getAllParamNamesList();
	//vector<string> updatedParamsList = client->getChangedParamsList();

	NSLog(@"Client holds %d params so far", (int) paramList.size());
	//NSLog(@"Client reports %d params changed since last check", (int)updatedParamsList.size());

	if(paramList.size() > 0 /*&& updatedParamsList.size() > 0*/){

		int c = 0;

		for(int i = 0; i < paramList.size(); i++){

			string paramName = paramList[i];
			RemoteUIParam p = client->getParamForName(paramName);

			map<string,ParamUI*>::iterator it = widgets.find(paramName);
			if ( it == widgets.end() ){	//not found, this is a new param... lets make an UI item for it

				//ParamUI *paramView = [[ParamUI alloc] initWithParam:p name: [name UTF8String] ID:i];
				//NSLog(@"%@", paramView);

				ParamUI * paramView = [[ParamUI alloc] initWithParam: p name: paramName ID: c client:client];
				cout << paramName << endl;
				c++;
				orderedKeys.push_back(paramName);
				widgets[paramName] = paramView;

				if (paramView){
					[paramViews addObject:paramView];
				}
			}
		}
	}
}


-(void) partialParamsUpdate{

	vector<string> paramList = client->getAllParamNamesList();

	for(int i = 0; i < paramList.size(); i++){

		string paramName = paramList[i];

		map<string,ParamUI*>::iterator it = widgets.find(paramName);
		if ( it == widgets.end() ){	//not found, this is a new param... lets make an UI item for it
			NSLog(@"uh?");
		}else{
			RemoteUIParam p = client->getParamForName(paramName);
			ParamUI * item = widgets[paramName];
			//[item updateParam:p];
			//[item updateUI];
		}
	}
	//	for( map<string,ParamUI*>::iterator ii = widgets.begin(); ii != widgets.end(); ++ii ){
	//		string key = (*ii).first;
	//		ParamUI* t = widgets[key];
	//		[t disableChanges];
	//	}

	[self.collectionView reloadData];
}


-(void) connect{

//	NSString * date = [[NSDate date] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil];

//	if (!connected){ //we are not connected, let's connect

//		int port = [portField.stringValue intValue];
//		bool OK = client->setup([addressField.stringValue UTF8String], port);
//		if (!OK){//most likely no network inerfaces available!
//			NSLog(@"Can't Setup ofxRemoteUI Client! Most likely no network interfaces available!");
//			[self showNotificationWithTitle:@"Cant Setup ofxRemoteUI Client!"
//								description:@"No Network Interface available?"
//										 ID:@"CantSetupClient"
//								   priority:2];
//			return;
//		}
//
//		[addressField setEnabled:false];
//		[portField setEnabled:false];
//		connectButton.title = DISCONNECT_STRING;
//		connectButton.state = 1;
//		connected = true;
//		printf("ofxRemoteUIClientOSX Connecting to %s\n", [addressField.stringValue UTF8String] );
//		[updateFromServerButton setEnabled: true];
//		[updateContinuouslyCheckbox setEnabled: true];
//		[statusImage setImage:nil];
//		//first load of vars
//		[self pressedSync:nil];
//		[self performSelector:@selector(pressedSync:) withObject:nil afterDelay:REFRESH_RATE];
//		[progress startAnimation:self];
//		connecting = TRUE;
//		needFullParamsUpdate = YES;
//		client->connect();
//		[logs appendToServerLog:[NSString stringWithFormat:@"%@ >> ## CLIENT CONNECTED ###################\n", date]];
//
//	}else{ // let's disconnect
//
//		RemoteUIClientCallBackArg arg;
//		arg.action = SERVER_DISCONNECTED;
//		arg.host = [addressField.stringValue UTF8String];
//		[logs log:arg];
//		arg.host = "offline";
//		[presetsMenu removeAllItems];
//		[groupsMenu removeAllItems];
//		[addressField setEnabled:true];
//		[portField setEnabled:true];
//		[updateFromServerButton setEnabled: false];
//		[updateContinuouslyCheckbox setEnabled:false];
//		if ([statusImage image] != [NSImage imageNamed:@"offline"])
//			[statusImage setImage:[NSImage imageNamed:@"offline"]];
//		[progress stopAnimation:self];
//		connecting = FALSE;
//		[self cleanUpGUIParams];
//		client->disconnect();
//		connectButton.state = 0;
//		connectButton.title = CONNECT_STRING;
//		[self layoutWidgetsWithConfig: [self calcLayoutParams]]; //update scrollbar
//		[logs appendToServerLog:[NSString stringWithFormat:@"%@ >> ## CLIENT DISCONNECTED ###################\n", date]];
//	}
}


-(void)update{

	if (client->isSetup()){
		//NSLog(@"update");
		client->updateAutoDiscovery(REFRESH_RATE);
		client->update(REFRESH_RATE);
	}

}

-(ofxRemoteUIClient *)getClient;{
	return client;
}



- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


#pragma mark collectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return paramViews.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"Cell";
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

//	for(id view in [cell subviews]){
//		[view removeFromSuperview ];
//		NSLog(@"remove %@ from %d",view, indexPath.row);
//	}

	if ([[cell subviews] count] > 0){
		ParamUI * paramView = [paramViews objectAtIndex:indexPath.row];
		//[paramView setNeedsLayout];
		[cell addSubview: [paramView getView]];

		[paramView setup];
	}
	//NSLog(@"addSubview %@ from %d",[recipeImages objectAtIndex:indexPath.row], indexPath.row);
	return cell;
}

@end