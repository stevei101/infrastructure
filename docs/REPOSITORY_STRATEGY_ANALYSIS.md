# Repository Strategy Analysis: Separate Repo vs Monorepo

## Question
Should infrastructure code live in a **separate repository** (`stevei101/infrastructure`) or as a **subdirectory** in the existing monorepo (`stevei101/infrastructure/`)?

## Current Situation

- **Current Structure**: `stevei101` is a monorepo containing:
  - `agentnav/`
  - `product-baseline-opensource/`
  - `cursor-ide/`
  - `infrastructure/` (newly created)

- **FR 008 Requirement**: "Extract GHA/Terraform Cloud code into a new sub-repo in gh org stevei101"

## Option 1: Separate Repository (`stevei101/infrastructure`)

### Pros ✅
1. **Reusable Workflows**: GitHub Actions `workflow_call` works best with separate repos
   - Project repos can call: `stevei101/infrastructure/.github/workflows/terraform-agentnav-reusable.yml@main`
   - Clean separation of concerns

2. **Independent Versioning**: 
   - Infrastructure can have its own release cycle
   - Tag infrastructure versions independently
   - Easier to track infrastructure changes

3. **Access Control**:
   - Different permissions for infrastructure vs application code
   - Can restrict who can modify infrastructure

4. **Reusability Across Projects**:
   - Projects outside the monorepo can use the infrastructure workflows
   - Not tied to the monorepo structure

5. **Follows FR 008 Requirement**: 
   - Explicitly asked for a "new sub-repo"

6. **Terraform Cloud Workspaces**:
   - Each project has its own workspace, separate repo aligns with this

### Cons ❌
1. **More Repositories to Manage**:
   - Need to create and maintain another repo
   - More places to check for changes

2. **Cross-Repo Coordination**:
   - Changes might need to be coordinated across repos
   - Slightly more complex workflow

3. **Initial Setup Complexity**:
   - Need to set up the new repo
   - Configure secrets in multiple places

## Option 2: Monorepo Subdirectory (`stevei101/infrastructure/`)

### Pros ✅
1. **Everything in One Place**:
   - Single repository to manage
   - Easier to discover and navigate
   - Single source of truth

2. **Simpler for Small Teams**:
   - Less overhead
   - No cross-repo dependencies

3. **Atomic Changes**:
   - Can update infrastructure and application code in same PR
   - Easier to coordinate changes

4. **Simpler CI/CD**:
   - All workflows in one place
   - No need to checkout multiple repos

### Cons ❌
1. **Limited Reusability**:
   - Can't easily use `workflow_call` from other repos
   - Would need to duplicate workflows or use different approach

2. **Tied to Monorepo**:
   - Projects outside the monorepo can't easily use the infrastructure code
   - Less flexible

3. **Doesn't Match FR 008**:
   - FR 008 specifically asked for a "new sub-repo"

4. **Access Control**:
   - Same permissions for infrastructure and application code
   - Can't restrict infrastructure changes separately

## Recommendation: **Separate Repository** 🎯

### Why?

1. **FR 008 Requirement**: The feature request explicitly asks for a "new sub-repo"

2. **Reusable Workflows**: The reusable workflow pattern (`workflow_call`) works best with separate repositories:
   ```yaml
   # In agentnav repo
   jobs:
     terraform:
       uses: stevei101/infrastructure/.github/workflows/terraform-agentnav-reusable.yml@main
   ```

3. **Future Flexibility**: 
   - Projects outside the monorepo can use the infrastructure
   - Can be used by other organizations/teams
   - More modular architecture

4. **Best Practices**: 
   - Infrastructure as Code (IaC) is often kept separate from application code
   - Allows independent versioning and release cycles
   - Better separation of concerns

5. **Terraform Cloud Alignment**: 
   - Each project has separate Terraform Cloud workspaces
   - Separate repo aligns with this separation

## Implementation

If choosing **Option 1 (Separate Repo)**:

1. Create `stevei101/infrastructure` repository on GitHub
2. Push the `infrastructure/` directory contents to the new repo
3. Update project repos to use reusable workflows
4. Configure secrets in the infrastructure repo (if needed)

If choosing **Option 2 (Monorepo)**:

1. Keep `infrastructure/` in the monorepo
2. Update workflows to work within the monorepo structure
3. Modify reusable workflow approach (use local paths instead of `workflow_call`)
4. Update documentation to reflect monorepo structure

## Hybrid Approach (Alternative)

You could also consider:
- Keep infrastructure code in monorepo for now
- Create separate repo later if needed
- Use git submodules to reference infrastructure from projects

However, this adds complexity and doesn't fully meet FR 008 requirements.

## Conclusion

**Recommendation: Use a separate repository** (`stevei101/infrastructure`)

This aligns with:
- ✅ FR 008 requirements
- ✅ Best practices for IaC
- ✅ Reusable workflow patterns
- ✅ Future flexibility
- ✅ Independent versioning

The slight increase in complexity is outweighed by the benefits of separation, reusability, and alignment with GitHub Actions best practices.

