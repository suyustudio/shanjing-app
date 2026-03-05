.class Landroidx/lifecycle/LiveData$LifecycleBoundObserver;
.super Landroidx/lifecycle/j;
.source "SourceFile"

# interfaces
.implements Landroidx/lifecycle/e;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Landroidx/lifecycle/j;",
        "Landroidx/lifecycle/e;"
    }
.end annotation


# instance fields
.field final b:Landroidx/lifecycle/g;


# virtual methods
.method d()Z
    .locals 2

    iget-object v0, p0, Landroidx/lifecycle/LiveData$LifecycleBoundObserver;->b:Landroidx/lifecycle/g;

    invoke-interface {v0}, Landroidx/lifecycle/g;->a()Landroidx/lifecycle/d;

    move-result-object v0

    invoke-virtual {v0}, Landroidx/lifecycle/d;->b()Landroidx/lifecycle/d$c;

    move-result-object v0

    sget-object v1, Landroidx/lifecycle/d$c;->g:Landroidx/lifecycle/d$c;

    invoke-virtual {v0, v1}, Landroidx/lifecycle/d$c;->a(Landroidx/lifecycle/d$c;)Z

    move-result v0

    return v0
.end method

.method public g(Landroidx/lifecycle/g;Landroidx/lifecycle/d$b;)V
    .locals 0

    iget-object p1, p0, Landroidx/lifecycle/LiveData$LifecycleBoundObserver;->b:Landroidx/lifecycle/g;

    invoke-interface {p1}, Landroidx/lifecycle/g;->a()Landroidx/lifecycle/d;

    move-result-object p1

    invoke-virtual {p1}, Landroidx/lifecycle/d;->b()Landroidx/lifecycle/d$c;

    move-result-object p1

    sget-object p2, Landroidx/lifecycle/d$c;->d:Landroidx/lifecycle/d$c;

    if-eq p1, p2, :cond_0

    invoke-virtual {p0}, Landroidx/lifecycle/LiveData$LifecycleBoundObserver;->d()Z

    move-result p1

    invoke-virtual {p0, p1}, Landroidx/lifecycle/j;->a(Z)V

    return-void

    :cond_0
    const/4 p1, 0x0

    throw p1
.end method
