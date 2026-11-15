import 'models/therapy_models.dart';

class AssessmentCatalog {
  AssessmentCatalog._();

  static const activities = <AssessmentActivityDefinition>[
    AssessmentActivityDefinition(
      id: 'story-narrative-recall',
      title: 'Story-Based Narrative Recall',
      kind: AssessmentActivityKind.story,
      instruction: 'Listen to the short story. Then answer questions about it.',
    ),
    AssessmentActivityDefinition(
      id: 'card-flip-matching',
      title: 'Card Flip Matching',
      kind: AssessmentActivityKind.cardMatching,
      instruction: 'Turn over two cards at a time and find every matching pair.',
    ),
    AssessmentActivityDefinition(
      id: 'numerical-sequence-recall',
      title: 'Numerical Sequence Recall',
      kind: AssessmentActivityKind.numericalSequence,
      instruction: 'Look carefully at each number sequence. Recall the requested number.',
    ),
    AssessmentActivityDefinition(
      id: 'object-location-test',
      title: 'Object Location Test',
      kind: AssessmentActivityKind.objectLocation,
      instruction: 'Study where each object is placed. Then remember its position.',
    ),
    AssessmentActivityDefinition(
      id: 'delayed-recall-test',
      title: 'Delayed Recall Test',
      kind: AssessmentActivityKind.delayedRecall,
      instruction: 'Remember these everyday words. You will be asked about them after a delay.',
    ),
    AssessmentActivityDefinition(
      id: 'pattern-recognition-recall',
      title: 'Pattern Recognition and Recall',
      kind: AssessmentActivityKind.patternRecall,
      instruction: 'Study each pattern. Then select the pattern you saw.',
    ),
    AssessmentActivityDefinition(
      id: 'everyday-object-recognition',
      title: 'Everyday Object Recognition and Recall',
      kind: AssessmentActivityKind.everydayObjects,
      instruction: 'Remember the familiar objects. Then identify the objects you saw.',
    ),
  ];
}
