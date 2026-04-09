import 'package:crimpy/models/sync/api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('API Models', () {
    test('CreateSessionRequest serializes correctly', () {
      final request = CreateSessionRequest(
        name: 'Test Session',
        notes: 'Test notes',
        duration: 300,
        isAssessment: false,
        sessionType: 0,
        repDatas: [
          RepDataRequest(
            index: 0,
            isRest: false,
            rightHand: true,
            duration: 10,
            targetWeight: 50.0,
            averageWeight: 48.5,
            gripPosition: 0,
          ),
        ],
      );

      final json = request.toJson();

      expect(json['name'], 'Test Session');
      expect(json['is_assessment'], false);
      expect(json['session_type'], 0);
      expect(json['rep_datas'], isA<List>());
      expect(json['rep_datas'].length, 1);
    });

    test('SessionResponse deserializes from backend JSON', () {
      final json = {
        'id': 123,
        'name': 'Backend Session',
        'notes': 'Notes',
        'date': '2026-04-09T10:00:00Z',
        'duration': 600,
        'is_assessment': true,
        'session_type': 1,
        'user_id': 'user_789',
      };

      final response = SessionResponse.fromJson(json);

      expect(response.id, 123);
      expect(response.name, 'Backend Session');
      expect(response.isAssessment, true);
      expect(response.userId, 'user_789');
    });

    test('CreateTrainingRequest serializes with rep templates', () {
      final request = CreateTrainingRequest(
        name: 'Test Training',
        isAssessment: false,
        isFavorite: true,
        repTemplates: [
          RepTemplateRequest(
            index: 0,
            isRest: false,
            rightHand: true,
            duration: 7,
            targetWeight: 60.0,
            gripPosition: 0,
          ),
        ],
      );

      final json = request.toJson();

      expect(json['name'], 'Test Training');
      expect(json['is_favorite'], true);
      expect(json['rep_templates'], isA<List>());
    });

    test('RepeaterResponse deserializes correctly', () {
      final json = {
        'id': 456,
        'sets': 3,
        'reps': 5,
        'worktime': 7,
        'resttime': 3,
        'set_rest': 180,
        'target_weight_right': 45.0,
        'target_weight_left': 40.0,
        'split_hand': true,
        'grip_position': 1,
      };

      final response = RepeaterResponse.fromJson(json);

      expect(response.id, 456);
      expect(response.sets, 3);
      expect(response.splitHand, true);
      expect(response.targetWeightRight, 45.0);
    });
  });
}
