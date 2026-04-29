import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:git_repo_list/API/api_call.dart';
import 'package:git_repo_list/model/model_repo.dart';
import 'package:git_repo_list/core/bridge.dart';

class RepoState {
  final ModelUserRepo myRepository;
  final List<ModelUserRepo> listRepoTask;

  const RepoState({
    required this.myRepository,
    required this.listRepoTask,
  });

  RepoState copyWith({
    ModelUserRepo? myRepository,
    List<ModelUserRepo>? listRepoTask,
  }) {
    return RepoState(
      myRepository: myRepository ?? this.myRepository,
      listRepoTask: listRepoTask ?? this.listRepoTask,
    );
  }
}

class RepoNotifier extends AsyncNotifier<RepoState> {
  @override
  Future<RepoState> build() async {
    // Watch shell user from app_core (or standalone defaults)
    final shellUser = ref.watch(shellUserProvider);
    final username = shellUser['username'] as String? ?? 'kanphob';

    return _fetchAll(username);
  }

  Future<RepoState> _fetchAll(String username) async {
    ModelUserRepo myRepository = ModelUserRepo();
    final myProfile = await APICall.getGitUsers(sUserName: username);
    if (myProfile != null && myProfile.isNotEmpty) {
      myRepository = ModelUserRepo.fromJson(myProfile);
    }

    final List<dynamic> listData = await APICall.getGitUsers();
    final List<ModelUserRepo> listRepoTask = [];
    if (listData.isNotEmpty) {
      for (final item in listData) {
        listRepoTask.add(ModelUserRepo.fromJson(item));
      }
    }

    return RepoState(myRepository: myRepository, listRepoTask: listRepoTask);
  }

  Future<void> loadReposForUser(ModelUserRepo md) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final List<dynamic> repoData =
        await APICall.getGitUsersRepository(md.sID);
    final List<ModelRepoData> repos = repoData
        .map((item) => ModelRepoData.fromJson(item))
        .toList();


    final updatedList = currentState.listRepoTask.map((user) {
      if (user.sID == md.sID) {
        user.listRepoData = repos;
      }
      return user;
    }).toList();

    final updatedMy = currentState.myRepository.sID == md.sID
        ? (currentState.myRepository..listRepoData = repos)
        : currentState.myRepository;

    state = AsyncData(currentState.copyWith(
      myRepository: updatedMy,
      listRepoTask: updatedList,
    ));
  }
}

final repoProvider = AsyncNotifierProvider<RepoNotifier, RepoState>(
  RepoNotifier.new,
  dependencies: [shellUserProvider],
);
