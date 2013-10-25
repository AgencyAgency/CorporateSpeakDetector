//
//  AAViewController.m
//  OpenEars
//
//  Created by Kyle Oba on 10/20/13.
//  Copyright (c) 2013 Kyle Oba. All rights reserved.
//

#import "AAViewController.h"
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>


@interface AAViewController ()

@property (nonatomic, strong) PocketsphinxController *pocketsphinxController;
@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;

@property (strong, nonatomic) NSArray *recognizedWords;

@property (weak, nonatomic) IBOutlet UILabel *hypothesisOutputLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreOutputLabel;
@property (weak, nonatomic) IBOutlet UILabel *utteranceOutputLabel;
@property (weak, nonatomic) IBOutlet UITextView *recognizedWordsTextView;
@property (weak, nonatomic) IBOutlet UITextView *detectedWordsTextView;
@end

@implementation AAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Setup view:
    self.hypothesisOutputLabel.text = @"...Listening for Corporate Speak...";
    self.scoreOutputLabel.text = @"...";
    self.utteranceOutputLabel.text = @"...";
    self.recognizedWordsTextView.text = [self.recognizedWords componentsJoinedByString:@", "];
    self.detectedWordsTextView.text = nil;
    
    // Start listening:
    [self.openEarsEventsObserver setDelegate:self];
    [self detectSpeech];
}


- (PocketsphinxController *)pocketsphinxController {
	if (_pocketsphinxController == nil) {
		_pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return _pocketsphinxController;
}


- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (_openEarsEventsObserver == nil) {
		_openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return _openEarsEventsObserver;
}

- (NSArray *)recognizedWords
{
    if (!_recognizedWords) {
        _recognizedWords = @[
                             @"AIR SUPPORT",
                             @"BANDWIDTH",
                             @"BHAG",
                             @"BIG ASK",
                             @"BIO-BREAK",
                             @"BRAIN DUMP",
                             @"BUY-IN",
                             @"CIRCLE BACK",
                             @"COME-TO-JESUS",
                             @"CORE COMPETENCY",
                             @"CYA",
                             @"DRILL DOWN",
                             @"DUCKS IN A ROW",
                             @"ELEVATOR PITCH",
                             @"EOD",
                             @"EXIT STRATEGY",
                             @"GOLDEN HANDCUFFS",
                             @"GREEN FATIGUE",
                             @"IDEATE",
                             @"LIAISE",
                             @"LOW-HANGING FRUIT",
                             @"MOMMY TRACK",
                             @"MOVE THE NEEDLE",
                             @"MULTITASK",
                             @"NET-NET",
                             @"OFFLINE",
                             @"ON THE SAME PAGE",
                             @"OPEN THE KIMONO",
                             @"OUT OF POCKET",
                             @"OUTSIDE THE BOX",
                             @"OUTSOURCE",
                             @"PAIN POINT",
                             @"PARADIGM SHIFT",
                             @"PARKING LOT",
                             @"PER",
                             @"PING",
                             @"PROACTIVE",
                             @"QUARTERBACK",
                             @"REPURPOSE",
                             @"RESULTS-DRIVEN",
                             @"REVERBIAGIZE",
                             @"RIGHTSIZED",
                             @"SACRED COW",
                             @"SHOOT THE PUPPY",
                             @"SILO",
                             @"SOCIALIZE",
                             @"STRATEGIC INITIATIVE",
                             @"SWEET SPOT",
                             @"SYNERGY",
                             @"TACTICAL",
                             @"TEAM PLAYER",
                             @"TRIAGE",
                             @"THROUGHPUT",
                             @"THROW UNDER THE BUS",
                             @"VALUE PROPOSITION",
                             @"WORK-LIFE BALANCE"
                             ];
    }
    return _recognizedWords;
}

- (void)detectSpeech
{
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:self.recognizedWords
                                                withFilesNamed:name
                                        forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    
    NSDictionary *languageGeneratorResults = nil;
    
    NSString *lmPath = nil;
    NSString *dicPath = nil;
	
    if([err code] == noErr) {
        
        languageGeneratorResults = [err userInfo];
		
        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
		
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }

    
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
    

}


#pragma mark -
#pragma mark - Pocket Sphinx Delegetes

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    self.hypothesisOutputLabel.text = hypothesis;
    self.scoreOutputLabel.text = recognitionScore;
    self.utteranceOutputLabel.text = utteranceID;

    NSString *oldWords = self.detectedWordsTextView.text;
    NSString *newLine = oldWords ? @"\n" : @"";
    newLine = [newLine stringByAppendingFormat:@"(%@) %@", recognitionScore, hypothesis];
    self.detectedWordsTextView.text = [oldWords stringByAppendingString:newLine];
    
    NSRange range = NSMakeRange(self.detectedWordsTextView.text.length - 1, 1);
    [self.detectedWordsTextView scrollRangeToVisible:range];
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail { // This can let you know that something went wrong with the recognition loop startup. Turn on OPENEARSLOGGING to learn why.
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}


@end
