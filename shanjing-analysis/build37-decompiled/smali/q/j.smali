.class public final synthetic Lq/j;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lq/a$a;


# instance fields
.field public final synthetic a:Lj0/k$d;


# direct methods
.method public synthetic constructor <init>(Lj0/k$d;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lq/j;->a:Lj0/k$d;

    return-void
.end method


# virtual methods
.method public final a(Z)V
    .locals 1

    iget-object v0, p0, Lq/j;->a:Lj0/k$d;

    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p1

    invoke-interface {v0, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method
