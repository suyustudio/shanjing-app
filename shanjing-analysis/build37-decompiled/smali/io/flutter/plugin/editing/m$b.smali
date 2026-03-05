.class Lio/flutter/plugin/editing/m$b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Li0/r$f;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/flutter/plugin/editing/m;-><init>(Landroid/view/View;Li0/r;Lio/flutter/plugin/platform/w;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Lio/flutter/plugin/editing/m;


# direct methods
.method constructor <init>(Lio/flutter/plugin/editing/m;)V
    .locals 0

    iput-object p1, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public a()V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-virtual {v0}, Lio/flutter/plugin/editing/m;->m()V

    return-void
.end method

.method public b()V
    .locals 2

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-static {v0}, Lio/flutter/plugin/editing/m;->b(Lio/flutter/plugin/editing/m;)Landroid/view/View;

    move-result-object v1

    invoke-virtual {v0, v1}, Lio/flutter/plugin/editing/m;->G(Landroid/view/View;)V

    return-void
.end method

.method public c(Ljava/lang/String;Landroid/os/Bundle;)V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-virtual {v0, p1, p2}, Lio/flutter/plugin/editing/m;->C(Ljava/lang/String;Landroid/os/Bundle;)V

    return-void
.end method

.method public d(IZ)V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-static {v0, p1, p2}, Lio/flutter/plugin/editing/m;->h(Lio/flutter/plugin/editing/m;IZ)V

    return-void
.end method

.method public e(DD[D)V
    .locals 6

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    move-wide v1, p1

    move-wide v3, p3

    move-object v5, p5

    invoke-static/range {v0 .. v5}, Lio/flutter/plugin/editing/m;->i(Lio/flutter/plugin/editing/m;DD[D)V

    return-void
.end method

.method public f(ILi0/r$b;)V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-virtual {v0, p1, p2}, Lio/flutter/plugin/editing/m;->E(ILi0/r$b;)V

    return-void
.end method

.method public g()V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-static {v0}, Lio/flutter/plugin/editing/m;->f(Lio/flutter/plugin/editing/m;)V

    return-void
.end method

.method public h(Z)V
    .locals 2

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1a

    if-lt v0, v1, :cond_2

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-static {v0}, Lio/flutter/plugin/editing/m;->g(Lio/flutter/plugin/editing/m;)Landroid/view/autofill/AutofillManager;

    move-result-object v0

    if-nez v0, :cond_0

    goto :goto_0

    :cond_0
    if-eqz p1, :cond_1

    iget-object p1, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-static {p1}, Lio/flutter/plugin/editing/m;->g(Lio/flutter/plugin/editing/m;)Landroid/view/autofill/AutofillManager;

    move-result-object p1

    invoke-virtual {p1}, Landroid/view/autofill/AutofillManager;->commit()V

    goto :goto_0

    :cond_1
    iget-object p1, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-static {p1}, Lio/flutter/plugin/editing/m;->g(Lio/flutter/plugin/editing/m;)Landroid/view/autofill/AutofillManager;

    move-result-object p1

    invoke-virtual {p1}, Landroid/view/autofill/AutofillManager;->cancel()V

    :cond_2
    :goto_0
    return-void
.end method

.method public i()V
    .locals 2

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-static {v0}, Lio/flutter/plugin/editing/m;->c(Lio/flutter/plugin/editing/m;)Lio/flutter/plugin/editing/m$d;

    move-result-object v0

    iget-object v0, v0, Lio/flutter/plugin/editing/m$d;->a:Lio/flutter/plugin/editing/m$d$a;

    sget-object v1, Lio/flutter/plugin/editing/m$d$a;->g:Lio/flutter/plugin/editing/m$d$a;

    if-ne v0, v1, :cond_0

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-static {v0}, Lio/flutter/plugin/editing/m;->d(Lio/flutter/plugin/editing/m;)V

    goto :goto_0

    :cond_0
    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-static {v0}, Lio/flutter/plugin/editing/m;->b(Lio/flutter/plugin/editing/m;)Landroid/view/View;

    move-result-object v1

    invoke-static {v0, v1}, Lio/flutter/plugin/editing/m;->e(Lio/flutter/plugin/editing/m;Landroid/view/View;)V

    :goto_0
    return-void
.end method

.method public j(Li0/r$e;)V
    .locals 2

    iget-object v0, p0, Lio/flutter/plugin/editing/m$b;->a:Lio/flutter/plugin/editing/m;

    invoke-static {v0}, Lio/flutter/plugin/editing/m;->b(Lio/flutter/plugin/editing/m;)Landroid/view/View;

    move-result-object v1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugin/editing/m;->F(Landroid/view/View;Li0/r$e;)V

    return-void
.end method
