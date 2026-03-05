.class Landroidx/core/view/t$l;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Landroidx/core/view/t;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "l"
.end annotation


# static fields
.field static final b:Landroidx/core/view/t;


# instance fields
.field final a:Landroidx/core/view/t;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Landroidx/core/view/t$b;

    invoke-direct {v0}, Landroidx/core/view/t$b;-><init>()V

    invoke-virtual {v0}, Landroidx/core/view/t$b;->a()Landroidx/core/view/t;

    move-result-object v0

    invoke-virtual {v0}, Landroidx/core/view/t;->a()Landroidx/core/view/t;

    move-result-object v0

    invoke-virtual {v0}, Landroidx/core/view/t;->b()Landroidx/core/view/t;

    move-result-object v0

    invoke-virtual {v0}, Landroidx/core/view/t;->c()Landroidx/core/view/t;

    move-result-object v0

    sput-object v0, Landroidx/core/view/t$l;->b:Landroidx/core/view/t;

    return-void
.end method

.method constructor <init>(Landroidx/core/view/t;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Landroidx/core/view/t$l;->a:Landroidx/core/view/t;

    return-void
.end method


# virtual methods
.method a()Landroidx/core/view/t;
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t$l;->a:Landroidx/core/view/t;

    return-object v0
.end method

.method b()Landroidx/core/view/t;
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t$l;->a:Landroidx/core/view/t;

    return-object v0
.end method

.method c()Landroidx/core/view/t;
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t$l;->a:Landroidx/core/view/t;

    return-object v0
.end method

.method d(Landroid/view/View;)V
    .locals 0

    return-void
.end method

.method e(Landroidx/core/view/t;)V
    .locals 0

    return-void
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 4

    const/4 v0, 0x1

    if-ne p0, p1, :cond_0

    return v0

    :cond_0
    instance-of v1, p1, Landroidx/core/view/t$l;

    const/4 v2, 0x0

    if-nez v1, :cond_1

    return v2

    :cond_1
    check-cast p1, Landroidx/core/view/t$l;

    invoke-virtual {p0}, Landroidx/core/view/t$l;->n()Z

    move-result v1

    invoke-virtual {p1}, Landroidx/core/view/t$l;->n()Z

    move-result v3

    if-ne v1, v3, :cond_2

    invoke-virtual {p0}, Landroidx/core/view/t$l;->m()Z

    move-result v1

    invoke-virtual {p1}, Landroidx/core/view/t$l;->m()Z

    move-result v3

    if-ne v1, v3, :cond_2

    invoke-virtual {p0}, Landroidx/core/view/t$l;->k()Landroidx/core/graphics/a;

    move-result-object v1

    invoke-virtual {p1}, Landroidx/core/view/t$l;->k()Landroidx/core/graphics/a;

    move-result-object v3

    invoke-static {v1, v3}, Landroidx/core/util/b;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_2

    invoke-virtual {p0}, Landroidx/core/view/t$l;->i()Landroidx/core/graphics/a;

    move-result-object v1

    invoke-virtual {p1}, Landroidx/core/view/t$l;->i()Landroidx/core/graphics/a;

    move-result-object v3

    invoke-static {v1, v3}, Landroidx/core/util/b;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_2

    invoke-virtual {p0}, Landroidx/core/view/t$l;->f()Landroidx/core/view/a;

    move-result-object v1

    invoke-virtual {p1}, Landroidx/core/view/t$l;->f()Landroidx/core/view/a;

    move-result-object p1

    invoke-static {v1, p1}, Landroidx/core/util/b;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_2

    goto :goto_0

    :cond_2
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method f()Landroidx/core/view/a;
    .locals 1

    const/4 v0, 0x0

    return-object v0
.end method

.method g(I)Landroidx/core/graphics/a;
    .locals 0

    sget-object p1, Landroidx/core/graphics/a;->e:Landroidx/core/graphics/a;

    return-object p1
.end method

.method h()Landroidx/core/graphics/a;
    .locals 1

    invoke-virtual {p0}, Landroidx/core/view/t$l;->k()Landroidx/core/graphics/a;

    move-result-object v0

    return-object v0
.end method

.method public hashCode()I
    .locals 3

    const/4 v0, 0x5

    new-array v0, v0, [Ljava/lang/Object;

    invoke-virtual {p0}, Landroidx/core/view/t$l;->n()Z

    move-result v1

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v1

    const/4 v2, 0x0

    aput-object v1, v0, v2

    invoke-virtual {p0}, Landroidx/core/view/t$l;->m()Z

    move-result v1

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v1

    const/4 v2, 0x1

    aput-object v1, v0, v2

    invoke-virtual {p0}, Landroidx/core/view/t$l;->k()Landroidx/core/graphics/a;

    move-result-object v1

    const/4 v2, 0x2

    aput-object v1, v0, v2

    invoke-virtual {p0}, Landroidx/core/view/t$l;->i()Landroidx/core/graphics/a;

    move-result-object v1

    const/4 v2, 0x3

    aput-object v1, v0, v2

    invoke-virtual {p0}, Landroidx/core/view/t$l;->f()Landroidx/core/view/a;

    move-result-object v1

    const/4 v2, 0x4

    aput-object v1, v0, v2

    invoke-static {v0}, Landroidx/core/util/b;->b([Ljava/lang/Object;)I

    move-result v0

    return v0
.end method

.method i()Landroidx/core/graphics/a;
    .locals 1

    sget-object v0, Landroidx/core/graphics/a;->e:Landroidx/core/graphics/a;

    return-object v0
.end method

.method j()Landroidx/core/graphics/a;
    .locals 1

    invoke-virtual {p0}, Landroidx/core/view/t$l;->k()Landroidx/core/graphics/a;

    move-result-object v0

    return-object v0
.end method

.method k()Landroidx/core/graphics/a;
    .locals 1

    sget-object v0, Landroidx/core/graphics/a;->e:Landroidx/core/graphics/a;

    return-object v0
.end method

.method l()Landroidx/core/graphics/a;
    .locals 1

    invoke-virtual {p0}, Landroidx/core/view/t$l;->k()Landroidx/core/graphics/a;

    move-result-object v0

    return-object v0
.end method

.method m()Z
    .locals 1

    const/4 v0, 0x0

    return v0
.end method

.method n()Z
    .locals 1

    const/4 v0, 0x0

    return v0
.end method

.method o(I)Z
    .locals 0

    const/4 p1, 0x1

    return p1
.end method

.method public p([Landroidx/core/graphics/a;)V
    .locals 0

    return-void
.end method

.method q(Landroidx/core/graphics/a;)V
    .locals 0

    return-void
.end method

.method r(Landroidx/core/view/t;)V
    .locals 0

    return-void
.end method

.method public s(Landroidx/core/graphics/a;)V
    .locals 0

    return-void
.end method
