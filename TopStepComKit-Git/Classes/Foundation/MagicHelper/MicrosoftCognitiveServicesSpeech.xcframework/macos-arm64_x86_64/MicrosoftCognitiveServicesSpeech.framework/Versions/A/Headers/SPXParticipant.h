//
// Copyright (c) Microsoft. All rights reserved.
// See https://aka.ms/csspeech/license for the full license information.
//

#import "SPXFoundation.h"
#import "SPXPropertyCollection.h"

/**
 * Represents a participant in a conversation transcribing session.
 *
 * Added in version 1.13.0.
 */
SPX_EXPORT
@interface SPXParticipant : NSObject

/**
 * The collection of properties and their values defined for this SPXParticipant.
 */
@property (readonly, nullable)id <SPXPropertyCollection> properties;

/**
 * The unique identifier for the participant.
 */
@property (nonatomic, copy, nullable)NSString *id;

/**
 * The participant's preferred spoken language.
 */
@property (nonatomic, copy, nullable)NSString *preferredLanguage;

/**
 * The participant's voice signature.
 */
@property (nonatomic, copy, nullable)NSString *voiceSignature;

/**
 * Create a Participant using user id, her/his preferred language and her/his voice signature.
 * If voice signature is empty then user will not be identified.
 *
 * @param userId user's Id.
 * @param preferredLanguage users' preferred language.
 * @param voiceSignature user's voice signature.
 * @return The Participant object.
 */
- (nullable instancetype)initFrom:(nonnull NSString *)userId preferredLanguage:(nonnull NSString *)preferredLanguage voiceSignature:(nonnull NSString *)voiceSignature
NS_SWIFT_UNAVAILABLE("Use the method with Swift-compatible error handling.");

/**
 * Create a Participant using user id, her/his preferred language and her/his voice signature.
 * If voice signature is empty then user will not be identified.
 *
 * @param userId user's Id.
 * @param preferredLanguage users' preferred language.
 * @param voiceSignature user's voice signature.
 * @return The Participant object.
 * @param outError error information.
 */
- (nullable instancetype)initFrom:(nonnull NSString *)userId preferredLanguage:(nonnull NSString *)preferredLanguage voiceSignature:(nonnull NSString *)voiceSignature error:(NSError * _Nullable * _Nullable)outError;

/**
 * Create a Participant using user id and her/his preferred language.
 *
 * @param userId user's Id.
 * @param preferredLanguage users' preferred language.
 * @return The Participant object.
 */
- (nullable instancetype)initFrom:(nonnull NSString *)userId preferredLanguage:(nonnull NSString *)preferredLanguage
NS_SWIFT_UNAVAILABLE("Use the method with Swift-compatible error handling.");

/**
 * Create a Participant using user id and her/his preferred language.
 *
 * @param userId user's Id.
 * @param preferredLanguage users' preferred language.
 * @return The Participant object.
 * @param outError error information.
 */
- (nullable instancetype)initFrom:(nonnull NSString *)userId preferredLanguage:(nonnull NSString *)preferredLanguage error:(NSError * _Nullable * _Nullable)outError;

/**
 * Create a Participant using user id.
 *
 * @param userId user's Id.
 * @return The Participant object.
 */
- (nullable instancetype)initFrom:(nonnull NSString *)userId
NS_SWIFT_UNAVAILABLE("Use the method with Swift-compatible error handling.");

/**
 * Create a Participant using user id.
 *
 * @param userId user's Id.
 * @return The Participant object.
 * @param outError error information.
 */
- (nullable instancetype)initFrom:(nonnull NSString *)userId error:(NSError * _Nullable * _Nullable)outError;

@end
