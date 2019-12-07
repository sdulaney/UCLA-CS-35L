import os, sys, zlib

class CommitNode:
    def __init__(self, commit_hash):
        """
        :type commit_hash: str
        """
        self.commit_hash = commit_hash
        self.associated_branches = set()
        self.parents = set()
        self.children = set()
        commit_obj_str = self.get_commit_obj_str_from_hash(commit_hash)
        commit_obj_lines = commit_obj_str.split("\n")
        for line in commit_obj_lines:
            line_words = line.split(" ")
            if line_words[0] == "parent":
                self.parents.add(line_words[1])
    def get_commit_obj_str_from_hash(self, commit_hash):
        top_level_git_dir = get_top_level_git_dir()
        commit_obj_file = open(os.path.join(top_level_git_dir, ".git/objects", commit_hash[0:2], commit_hash[2:40]), "rb")
        return zlib.decompress(commit_obj_file.read()).decode()
    def __str__(self):
        return f'commit_hash: {self.commit_hash}, parents: {self.parents}, children: {self.children}, associated_branches: {self.associated_branches}'

def get_top_level_git_dir():
    # Discover the .git directory
    top_level_git_dir = os.getcwd()
    while os.path.isdir(os.path.join(top_level_git_dir, ".git")) == False:
        if top_level_git_dir == "/":
            sys.stderr.write("Not inside a Git repository\n")
            sys.exit(1)
        top_level_git_dir = os.path.dirname(top_level_git_dir)
    return top_level_git_dir

def get_local_branch_names(top_level_git_dir):
    # Get the list of local branch names
    local_branch_names = list()
    local_branch_dir = os.path.join(top_level_git_dir, ".git/refs/heads")
    for root, dirs, files in os.walk(local_branch_dir):
        if root == os.path.join(top_level_git_dir, ".git/refs/heads"):
            local_branch_names.extend(files)
        else:
            for file in files:
                local_branch_names.append(os.path.join(os.path.relpath(root, local_branch_dir), file))
    return local_branch_names

def build_commit_graph(top_level_git_dir, local_branch_names):
    # Build the commit graph
    commit_graph = {}
    root_commits_set = set()
    for branch in local_branch_names:
        # Get commit hash of branch head
        f = open(os.path.join(top_level_git_dir, ".git/refs/heads", branch), "r")
        branch_head_commit_hash = f.read()
        # Do DFS starting from the branch head using a stack
        vertex = CommitNode(branch_head_commit_hash[0:40])
        if vertex.commit_hash in commit_graph:
            commit_graph[vertex.commit_hash].associated_branches.add(branch)
        else:
            vertex.associated_branches.add(branch)
        stack = [(vertex, [vertex])]
        visited = set()
        while stack:
            v, path = stack.pop()
            visited.add(v)
            if len(v.parents) == 0:
                root_commits_set.add(v.commit_hash)
            if not v.commit_hash in commit_graph:
                commit_graph[v.commit_hash] = v
            else:
                for child in sorted(list(v.children)):
                    commit_graph[v.commit_hash].children.add(child)
            for parent in sorted(list(v.parents)):
                if parent not in visited:
                    parent_obj = CommitNode(parent)
                    parent_obj.children.add(v.commit_hash)
                    stack.append((parent_obj, path + [parent_obj]))
    # The output should be deterministic
    root_commits = sorted(list(root_commits_set))
    return commit_graph, root_commits

def topo_sort_commits(commit_graph, root_commits):
    # Generate a topological ordering of the commits in the graph
    # Use list implementation of queue
    result = []
    visited = set()
    # For each node s in root_commits, if that s has not been visited, then run DFS with s as the starting point and trace through the children
    for commit in root_commits:
        if commit not in visited:
            s = commit_graph[commit]
            dfs_stack = [s]
            aux_stack = []
            while dfs_stack:
                v = dfs_stack.pop()
                visited.add(v.commit_hash)
                # Default to True for when node has no children
                children_processed = True
                for child_commit_hash in sorted(list(v.children)):
                    if child_commit_hash not in visited:
                        children_processed = False
                if children_processed == False:
                    aux_stack.append(v)
                else:
                    if v not in result:
                        result.append(v)
                # The output should be deterministic
                children_sorted = sorted(list(v.children))
                for child_commit_hash in children_sorted:
                    if child_commit_hash not in visited:
                        dfs_stack.append(commit_graph[child_commit_hash])
                # Check if we finished processing the children for previously visited nodes
                finished_proc_node = True
                while aux_stack and finished_proc_node == True:
                    node = aux_stack.pop()
                    for child_commit_hash in sorted(list(node.children)):
                        if child_commit_hash not in visited:
                            finished_proc_node = False
                    if finished_proc_node == False:
                        aux_stack.append(node)
                    else:
                        if node not in result:
                            result.append(node)
    return result

def print_sticky_start(commit_obj):
    # The output should be deterministic
    if len(commit_obj.children) == 0:
        print("=")
    else:
        children_sorted = sorted(list(commit_obj.children))
        print("=" + " ".join(children_sorted))

def print_topo_order_commits(result):
    for i in range(len(result)):
        if len(result[i].associated_branches) != 0:
            # The output should be deterministic
            branches_sorted = sorted(list(result[i].associated_branches))
            print(result[i].commit_hash + " " + " ".join(branches_sorted))
        else:
            print(result[i].commit_hash)
        if i != len(result)-1:
            if result[i + 1].commit_hash not in result[i].parents:
                # Insert a "sticky end" followed by an empty line
                # The output should be deterministic
                if len(result[i].parents) == 0:
                    print("=\n")
                    print_sticky_start(result[i + 1])
                else:
                    parents_sorted = sorted(list(result[i].parents))
                    print(" ".join(parents_sorted) + "=\n")
                    print_sticky_start(result[i + 1])

# Keep the function signature,
# but replace its body with your implementation
def topo_order_commits():
    top_level_git_dir = get_top_level_git_dir()
    local_branch_names = get_local_branch_names(top_level_git_dir)
    commit_graph, root_commits= build_commit_graph(top_level_git_dir, local_branch_names)
    result = topo_sort_commits(commit_graph, root_commits)
    print_topo_order_commits(result)
    #raise NotImplementedError


if __name__ == '__main__':
    topo_order_commits()

    
