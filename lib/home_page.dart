import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'model/model_repo.dart';
import 'providers/navigation_provider.dart';
import 'providers/repo_provider.dart';
import 'utils/shake_widget.dart';
import 'core/bridge.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navIndex = ref.watch(navigationProvider);
    final repoAsync = ref.watch(repoProvider);

    return repoAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) {
        return Scaffold(
          body: Center(child: Text('Error: $err')),
        );
      },
      data: (data) {
        const double dHeightImg = 180;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: NestedScrollView(
            physics: const BouncingScrollPhysics(),
            floatHeaderSlivers: true,
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext ctx, bool innerBoxIsScrolled) {
              return <Widget>[
                _buildAppHeader(ctx, data, dHeightImg),
              ];
            },
            body: navIndex == 0
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        if (data.listRepoTask.isNotEmpty)
                          _buildHeaderList(
                              context, _searchController, _searchText),
                        _buildHomePageBody(
                            context, ref, data, _searchText),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.blue,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.task_alt_outlined), label: 'Second'),
            ],
            currentIndex: navIndex,
            onTap: (index) {
              ref.read(navigationProvider.notifier).state = index;
            },
          ),
        );
      },
    );
  }

  // ─── App Header (SliverAppBar) ───────────────────────────────────────────

  Widget _buildAppHeader(
      BuildContext context, RepoState data, double dHeightImg) {
    final user = ref.watch(shellUserProvider);
    
    return SliverAppBar(
      pinned: true,
      snap: false,
      floating: false,
      backgroundColor: const Color(0xFF6C63FF),
      leadingWidth: 50,
      expandedHeight: 160,
      actions: [
        IconButton(
          icon: Icon(
            ref.watch(isStandaloneProvider) ? Icons.exit_to_app : Icons.logout,
            color: Colors.white,
          ),
          onPressed: () {
            ref.read(shellLogoutProvider)();
          },
        ),
      ],
      flexibleSpace: LayoutBuilder(
          builder: (BuildContext ctx, BoxConstraints constraints) {
        final top = constraints.biggest.height;
        return FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 0, bottom: 10),
          title: Opacity(
            opacity: top <= 100 ? 1 : 0,
            child: Row(
              children: [
                const SizedBox(width: 10),
                Text(
                  '${user['username'] ?? 'GitRepo'} List',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          background: _ShellProfileHeader(user: user),
        );
      }),
    );
  }
}

Widget _buildProfileImage(String url) {
  if (url.isEmpty) {
    return Image.asset(
      'assets/images/task.png',
      fit: BoxFit.cover,
    );
  }
  return CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    placeholder: (context, url) => Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.blue,
          ),
        ),
      ),
    ),
    errorWidget: (context, url, error) => Image.asset(
      'assets/images/task.png',
      fit: BoxFit.cover,
    ),
  );
}

class _ShellProfileHeader extends StatelessWidget {
  final Map<String, dynamic> user;
  const _ShellProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user['displayName'] ?? user['username'] ?? 'User';
    final email = user['email'] ?? '';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

  // ─── Search Header ───────────────────────────────────────────────────────

  Widget _buildHeaderList(
    BuildContext context,
    TextEditingController searchController,
    String searchText,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade100,
              ),
              child: TextField(
                textInputAction: TextInputAction.done,
                controller: searchController,
                decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(left: 10, right: 10),
                    hintText: 'Search Title or Description',
                    border: const OutlineInputBorder(),
                    fillColor: Colors.grey.shade300,
                    suffixIcon: searchText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_sharp),
                            onPressed: () {
                              searchController.clear();
                            },
                          )
                        : null),
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  // ─── Main Body (List) ────────────────────────────────────────────────────

  Widget _buildHomePageBody(BuildContext context, WidgetRef ref,
      RepoState data, String searchText) {
    final filtered = data.listRepoTask
        .where((u) =>
            u.sID.contains(searchText) || u.sUserName.contains(searchText))
        .toList();

    return Container(
      color: Colors.transparent,
      child: filtered.isNotEmpty
          ? ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  background: _backgroundStackBehindDismiss(),
                  confirmDismiss: (DismissDirection direction) async {
                    return await _onDismissShowDialog(
                        context, direction, filtered[index]);
                  },
                  key: ObjectKey(filtered[index]),
                  child: _buildListItem(
                      context, ref, filtered[index], index),
                );
              })
          : Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 50,
                    ),
                    child: Image.asset(
                      'assets/images/task.png',
                      filterQuality: FilterQuality.medium,
                      fit: BoxFit.fitWidth,
                      scale: 2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    searchText.isEmpty
                        ? 'No Repo Available'
                        : 'No Results Found',
                    style: const TextStyle(fontSize: 30),
                  ),
                ],
              ),
            ),
    );
  }

  // ─── List Item Card ──────────────────────────────────────────────────────

  Widget _buildListItem(BuildContext context, WidgetRef ref,
      ModelUserRepo md, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(color: Colors.blue.shade700, width: 1),
      ),
      child: ListTile(
        onTap: () async {
          await _showFancyCustomDialog(context, ref, md: md);
        },
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        leading: InkWell(
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (BuildContext ctx, _, __) {
                    return Material(
                        color: Colors.black38,
                        child: Container(
                          padding: const EdgeInsets.all(30.0),
                          child: InkWell(
                            child: Hero(
                              tag: md.sUserName.isNotEmpty
                                  ? 'avatar-${md.sUserName}'
                                  : 'avatar-${md.sID}',
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: _buildProfileImage(md.sImgProfileUrl),
                              ),
                            ),
                            onTap: () => Navigator.pop(ctx),
                          ),
                        ));
                  }));
            },
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xffffeac4)),
                  borderRadius: BorderRadius.circular(5)),
              child: Hero(
                tag: md.sID,
                child: SizedBox(
                    width: 60,
                    height: 80,
                    child: _buildProfileImage(md.sImgProfileUrl)),
              ),
            )),
        title: Row(
          children: [
            const SizedBox(width: 5),
            Expanded(
                child: Text(md.sID,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 20))),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: TextButton(
              style: const ButtonStyle(alignment: Alignment.centerLeft),
              child: Text(md.sUserGitUrl),
              onPressed: () async {
                if (!await launchUrl(Uri.parse(md.sUserGitUrl))) {
                  throw 'Could not launch url';
                }
              },
            ))
          ],
        ),
      ),
    );
  }

  // ─── Dismiss helpers ─────────────────────────────────────────────────────

  Future<bool?> _onDismissShowDialog(BuildContext context,
      DismissDirection direction, ModelUserRepo md) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Confirm'),
            content:
                const Text('Are you sure you wish to delete this item?'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('DELETE'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('CANCEL'),
              ),
            ],
          );
        });
  }

  Widget _backgroundStackBehindDismiss() {
    return Container(
      color: Colors.red,
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white),
            Text('Move to trash', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Sheet Detail ─────────────────────────────────────────────────

  Future<int> _showFancyCustomDialog(BuildContext context, WidgetRef ref,
      {ModelUserRepo? md}) async {
    if (md != null) {
      // Fetch repos before opening the sheet
      await ref.read(repoProvider.notifier).loadReposForUser(md);
    }

    if (!context.mounted) return 0;

    int iRet = 0;
    iRet = await showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Wrap(children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height / 1.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: StatefulBuilder(
                  builder: (ctx2, setState) {
                    return Container(
                      margin: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(
                        children: <Widget>[
                          _buildBodyFormTask(ctx2, md!, setState),
                          _buildHeaderFormTask(),
                          _buildConfirmButtonFormTask(ctx2),
                          _buildCloseButtonFormTask(ctx2),
                        ],
                      ),
                    );
                  },
                ))
          ]);
        });
    return iRet;
  }

  // ─── Bottom Sheet widgets ────────────────────────────────────────────────

  Widget _buildHeaderFormTask() {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        color: Color(0xFFE0E7FF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const Align(
          alignment: Alignment.center,
          child: Text(
            'GitHub Repository',
            style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 20,
                fontWeight: FontWeight.w600),
          )),
    );
  }

  Widget _buildConfirmButtonFormTask(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFF6C63FF),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: const Align(
            alignment: Alignment.center,
            child: Text(
              'Done',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButtonFormTask(BuildContext context) {
    return Align(
      alignment: const Alignment(1.05, -1.05),
      child: InkWell(
        onTap: () => Navigator.pop(context, 0),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(Icons.close, color: Colors.red, size: 35),
        ),
      ),
    );
  }

  Widget _buildBodyFormTask(
      BuildContext context, ModelUserRepo md, StateSetter setState) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(left: 5, right: 5, top: 60),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(children: [
          ShakeWidget(child: _buildUserDetail(context, md)),
          const Row(
            children: [
              Text('Repository List',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
              child: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: [
              _buildRepositoryList(md),
              const SizedBox(height: 80),
            ],
          )),
        ]));
  }

  Widget _buildUserDetail(BuildContext context, ModelUserRepo md) {
    return Column(
      children: [
        const Row(
          children: [
            Text(
              'User Detail',
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.only(bottom: 5, right: 5),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 5),
                  leading: InkWell(
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext ctx, _, __) {
                              return Material(
                                  color: Colors.black38,
                                  child: Container(
                                    padding: const EdgeInsets.all(30.0),
                                    child: InkWell(
                                      child: SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: _buildProfileImage(md.sImgProfileUrl),
                                      ),
                                      onTap: () => Navigator.pop(ctx),
                                    ),
                                  ));
                            }));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xffffeac4)),
                            borderRadius: BorderRadius.circular(5)),
                        child: Hero(
                          tag: md.sID,
                          child: SizedBox(
                            width: 60,
                            height: 80,
                            child: _buildProfileImage(md.sImgProfileUrl),
                          ),
                        ),
                      )),
                  title: Row(
                    children: [
                      const SizedBox(width: 5),
                      Expanded(
                          child: Text(md.sID,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20))),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: TextButton(
                        style: const ButtonStyle(
                            alignment: Alignment.centerLeft),
                        child: Text(md.sUserGitUrl),
                        onPressed: () async {
                          if (!await launchUrl(
                              Uri.parse(md.sUserGitUrl))) {
                            throw 'Could not launch url';
                          }
                        },
                      ))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepositoryList(ModelUserRepo md) {
    return Column(
      children: [
        const SizedBox(height: 5),
        (md.listRepoData != null && md.listRepoData!.isNotEmpty)
            ? ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(height: 1, thickness: 1);
                },
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: md.listRepoData!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.all(5),
                    title: Text(md.listRepoData![index].name ?? '',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: TextButton(
                          style: const ButtonStyle(
                              alignment: Alignment.centerLeft),
                          child: Text(
                            md.listRepoData![index].url ?? '',
                            textAlign: TextAlign.start,
                          ),
                          onPressed: () async {
                            if (!await launchUrl(Uri.parse(
                                md.listRepoData![index].url ?? ''))) {
                              throw 'Could not launch url';
                            }
                          },
                        ))
                      ],
                    ),
                  );
                })
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_outlined,
                          size: 60, color: Colors.grey.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      const Text(
                        'No Repositories',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This user has no public repositories.',
                        style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }


