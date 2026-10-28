import 'package:graphql_parser2/graphql_parser2.dart';

enum DocumentLimit {
  depth,
  selections,
  aliases,
  fragmentCycle,
  unknownFragment
}

typedef DocumentLimitBreach = ({DocumentLimit limit, int max});

final class DocumentLimits {
  /// [maxDepth] é o maior aninhamento de seleções, [maxSelections] o total de
  /// nós visitados (campo, espalhamento e fragmento em linha, com os
  /// fragmentos expandidos) e [maxAliases] o total de apelidos. Ex.:
  /// `DocumentLimits(maxDepth: 15, maxSelections: 1000, maxAliases: 10)`.
  const DocumentLimits({
    required this.maxDepth,
    required this.maxSelections,
    required this.maxAliases,
  });

  final int maxDepth;
  final int maxSelections;
  final int maxAliases;

  /// O primeiro teto que [operation] de [document] passa, ou nulo. Todo nó
  /// visitado conta em [maxSelections], tenha campo ou não, e a contagem para
  /// assim que um teto estoura: um fragmento repetido em cascata custa no
  /// máximo [maxSelections] passos. O espalhamento de fragmento que não existe
  /// é [DocumentLimit.unknownFragment]; o fragmento que se inclui a si mesmo,
  /// direto ou por outro, é [DocumentLimit.fragmentCycle].
  DocumentLimitBreach? breachOf(
    DocumentContext document,
    OperationDefinitionContext operation,
  ) {
    final fragments = {
      for (final f
          in document.definitions.whereType<FragmentDefinitionContext>())
        f.name: f,
    };
    var selections = 0;
    var aliases = 0;
    final open = <String?>{};

    DocumentLimitBreach? walk(SelectionSetContext? set, int depth) {
      if (set == null) return null;
      if (depth > maxDepth) return (limit: DocumentLimit.depth, max: maxDepth);
      for (final selection in set.selections) {
        if (++selections > maxSelections) {
          return (limit: DocumentLimit.selections, max: maxSelections);
        }
        final field = selection.field;
        final spread = selection.fragmentSpread;
        final inline = selection.inlineFragment;
        DocumentLimitBreach? breach;
        if (field != null) {
          if (field.fieldName.alias != null && ++aliases > maxAliases) {
            return (limit: DocumentLimit.aliases, max: maxAliases);
          }
          breach = walk(field.selectionSet, depth + 1);
        } else if (inline != null) {
          breach = walk(inline.selectionSet, depth);
        } else if (spread != null) {
          final target = fragments[spread.name];
          if (target == null) {
            return (limit: DocumentLimit.unknownFragment, max: 0);
          }
          if (!open.add(spread.name)) {
            return (limit: DocumentLimit.fragmentCycle, max: 0);
          }
          breach = walk(target.selectionSet, depth);
          open.remove(spread.name);
        }
        if (breach != null) return breach;
      }
      return null;
    }

    return walk(operation.selectionSet, 1);
  }
}
